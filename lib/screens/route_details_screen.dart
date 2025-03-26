// lib/screens/route_details_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Models
import '../models/stop.dart';
import '../models/barcode_scan.dart';
import '../models/photo.dart';
import '../models/signature.dart';

// Services
import '../services/photo_service.dart';
import '../services/scan_service.dart';
import '../services/signature_service.dart';
import '../services/database_service.dart';
import '../services/location_service.dart';
import '../services/sync_service.dart';
import '../services/app_state.dart';

// Widgets
import '../widgets/stop_list_item.dart';

class RouteDetailsScreen extends StatefulWidget {
  const RouteDetailsScreen({Key? key}) : super(key: key);

  @override
  _RouteDetailsScreenState createState() => _RouteDetailsScreenState();
}

class _RouteDetailsScreenState extends State<RouteDetailsScreen> {
  bool _processing = false;

  Future<void> _completeStop(Stop stop) async {
    // If it's already completed or we are processing, skip
    if (_processing || stop.completed) return;
    setState(() => _processing = true);

    try {
      // 1. Scan a barcode
      final BarcodeScan? scanResult = await ScanService.scanBarcode();
      if (scanResult == null) {
        setState(() => _processing = false);
        return;
      }

      // 2. Take a photo
      final Photo? photo = await PhotoService.takePhoto();
      if (photo == null) {
        setState(() => _processing = false);
        return;
      }

      // 3. Capture a signature
      final Signature? signature = await SignatureService.captureSignature(context);
      if (signature == null) {
        setState(() => _processing = false);
        return;
      }

      // Convert stop.id / routeId (String) to int if your BarcodeScan/Photo/Signature 
      // classes store them as int. If those classes also store them as String, skip parse.
      final int? stopIdAsInt = int.tryParse(stop.id);
      final int? routeIdAsInt = int.tryParse(stop.routeId);

      // Assign them to the captured items
      // If your BarcodeScan uses 'int? stopId;' do:
      scanResult.stopId = stopIdAsInt;
      scanResult.routeId = routeIdAsInt;

      // If Photo has 'int? stopId;' do:
      photo.stopId = stopIdAsInt;
      photo.routeId = routeIdAsInt;

      // If Signature has 'int? stopId;' do:
      signature.stopId = stopIdAsInt;
      signature.routeId = routeIdAsInt;

      // If your model fields are strings, just do:
      // scanResult.stopId = stop.id;

      // Save data to local DB
      await DatabaseService.insertBarcodeScan(scanResult);
      await DatabaseService.insertPhoto(photo);
      await DatabaseService.insertSignature(signature);

      // Mark the stop as completed
      final now = DateTime.now();
      double? lat;
      double? lng;

      try {
        final pos = await LocationService.getCurrentLocation();
        if (pos != null) {
          lat = pos.latitude;
          lng = pos.longitude;
        }
      } catch (_) {}

      stop.completed = true;
      stop.completedAt = now;
      stop.latitude = lat;
      stop.longitude = lng;

      await DatabaseService.updateStopDelivered(stop);

      // Update in-memory state
      final appState = context.read<AppState>();
      // Because addBarcodeScan needs a string? If so:
      appState.addBarcodeScan(stop.id, scanResult);
      appState.addPhoto(stop.id, photo);
      appState.setSignature(stop.id, signature);
      appState.markStopDelivered(stop.id, deliveredAt: now, lat: lat, lng: lng);

      // Attempt immediate sync
      try {
        await SyncService.syncStopData(stop);
      } catch (_) {
        // If sync fails, it remains unsynced for a later retry
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stop "${stop.name}" completed.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to complete stop.')),
      );
    } finally {
      setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // We'll read the list of stops from AppState
    final stops = context.select<AppState, List<Stop>>((s) => s.stops);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Details'),
      ),
      body: ListView.builder(
        itemCount: stops.length,
        itemBuilder: (context, index) {
          final stop = stops[index];
          return StopListItem(
            stop: stop,
            onTap: () => _completeStop(stop),
            onNavigate: () {
              if (stop.address.isNotEmpty) {
                LocationService.openMap(stop.address);
              }
            },
          );
        },
      ),
    );
  }
}
