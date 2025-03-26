// lib/services/sync_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

import '../config.dart';              // <-- So we can check Config.isTesting
import '../models/stop.dart';
import 'database_service.dart';
import '../utils/constants.dart';

class SyncService {
  /// Download route data from API and save to local database, or load from local
  /// fallback file if Config.isTesting == true.
  static Future<List<Stop>?> fetchRoute() async {
    // 1) Check the testing flag first
    if (Config.isTesting) {
      // Bypass HTTP. Load local SQL file instead
      print('Loading local fallback route data...');
      try {
        // Suppose you store the fallback file at assets/demoRoutes/demo_data.txt
        final sqlText = await rootBundle.loadString('assets/demoRoutes/demo_data.txt');

        // We'll clear the DB so there's no conflict
        await DatabaseService.clearAllData();

        // We'll split the file on semicolons, executing each statement
        final statements = sqlText.split(';');
        for (var stmt in statements) {
          final line = stmt.trim();
          if (line.isEmpty) continue;
          // Example: we only run lines that start with INSERT or UPDATE
          // or you can remove the if-check to run everything
          if (line.toUpperCase().startsWith('INSERT') ||
              line.toUpperCase().startsWith('UPDATE') ||
              line.toUpperCase().startsWith('BEGIN') ||
              line.toUpperCase().startsWith('COMMIT')) {
            // We'll call a method on DatabaseService or do direct SQL
            await DatabaseService.executeRawSql(line + ';');
          }
        }
        // After loading, return the list of stops from local DB
        return DatabaseService.getStops();
      } catch (e) {
        // If the file is missing or parse fails, we just return null or handle error
        return null;
      }
    }

    // 2) Normal (non-testing) mode: proceed with live API call
    try {
      final url = Uri.parse(Constants.apiBaseUrl + Constants.routeEndpoint);
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        int routeId = 0;
        List<dynamic> stopsData;

        if (data is List) {
          stopsData = data;
        } else if (data is Map) {
          // Possibly a JSON object with 'routeId' and 'stops'
          routeId = data['routeId'] is int
              ? data['routeId']
              : int.tryParse(data['routeId']?.toString() ?? '') ?? 0;
          stopsData = data['stops'] is List ? data['stops'] : [];
        } else {
          stopsData = [];
        }

        final List<Stop> stops = [];
        for (var item in stopsData) {
          if (item is Map) {
            int stopId = item['id'] is int
                ? item['id']
                : int.tryParse(item['id']?.toString() ?? '') ?? 0;
            String name = item['name']?.toString() ?? 'Stop $stopId';
            String address = item['address']?.toString() ?? '';
            int rid = routeId;
            if (rid == 0) {
              rid = (item['routeId'] is int)
                  ? item['routeId']
                  : int.tryParse(item['routeId']?.toString() ?? '') ?? 0;
            }
            int seq = (item['sequence'] is int)
                ? item['sequence']
                : int.tryParse(item['sequence']?.toString() ?? '') ??
                    (stops.length + 1);

            final stop = Stop(
              id: stopId.toString(),
              routeId: rid.toString(),
              sequence: seq,
              name: name,
              address: address,
            );
            stops.add(stop);
          }
        }

        if (stops.isNotEmpty) {
          await DatabaseService.clearAllData();
          await DatabaseService.insertStops(stops);
        }
        return stops;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Sync all stops that are 'completed' but not 'uploaded'
  static Future<bool> syncPendingData() async {
    try {
      List<Stop> allStops = await DatabaseService.getStops();
      List<Stop> pending = allStops.where((s) => s.completed && !s.uploaded).toList();

      bool allSuccessful = true;
      for (Stop stop in pending) {
        try {
          await syncStopData(stop);
        } catch (_) {
          allSuccessful = false;
        }
      }
      return allSuccessful;
    } catch (e) {
      return false;
    }
  }

  /// Sync a single stop's delivery data
  static Future<void> syncStopData(Stop stop) async {
    // If not completed, skip
    if (!stop.completed) return;

    final url = Uri.parse(Constants.apiBaseUrl + Constants.syncEndpoint);
    final request = http.MultipartRequest('POST', url);

    // Text fields
    request.fields['stopId'] = stop.id;
    request.fields['routeId'] = stop.routeId;
    request.fields['completedAt'] =
        stop.completedAt?.toIso8601String() ?? DateTime.now().toIso8601String();

    if (stop.latitude != null && stop.longitude != null) {
      request.fields['latitude'] = stop.latitude.toString();
      request.fields['longitude'] = stop.longitude.toString();
    }

    if (stop.barcodes.isNotEmpty) {
      request.fields['barcodes'] = stop.barcodes.join(',');
    }

    if (stop.photoPath != null && stop.photoPath!.isNotEmpty) {
      final file = File(stop.photoPath!);
      if (file.existsSync()) {
        request.files.add(await http.MultipartFile.fromPath('photo', file.path));
      }
    }
    // Additional logic for multiple photos, signature, etc. if you have them

    final response = await http.Response.fromStream(await request.send());
    if (response.statusCode == 200 || response.statusCode == 201) {
      stop.uploaded = true;
      await DatabaseService.updateStopDelivered(stop);
    } else {
      throw Exception('Failed to sync stop ${stop.id}');
    }
  }
}
