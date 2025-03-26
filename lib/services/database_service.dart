// lib/services/database_service.dart

import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/stop.dart';
import '../models/route.dart';  // Import RouteModel for getRoutes()
 
class DatabaseService {
  static Database? _db;

  static Future<Database> _openDatabase() async {
    if (_db != null) return _db!;
    final databasesPath = await getDatabasesPath();
    final dbPath = p.join(databasesPath, 'ctfo_demo.db');
    _db = await openDatabase(
      dbPath, 
      version: 1, 
      onCreate: (db, version) async {
        // Basic onCreate: create Stops table
        await db.execute('''
          CREATE TABLE IF NOT EXISTS Stops (
            id INTEGER PRIMARY KEY,
            routeId TEXT,
            sequence INTEGER,
            name TEXT,
            address TEXT,
            completed INTEGER,
            uploaded INTEGER,
            completedAt TEXT,
            latitude REAL,
            longitude REAL
          )
        ''');
        // Note: Other tables (routelist, addressdetaillist, etc.) will be created in importDemoData for testing mode
      }
    );
    return _db!;
  }

  /// Import demo route data from assets (testing mode).
  static Future<void> importDemoData() async {
    final db = await _openDatabase();
    // Create necessary tables for demo data if not exist
    await db.execute('''
      CREATE TABLE IF NOT EXISTS routelist (
        routeid TEXT,
        jobid TEXT,
        jobdetailid TEXT,
        interfacetype TEXT,
        city TEXT,
        state TEXT,
        zip TEXT,
        datevalidfrom INTEGER,
        datevalidto INTEGER,
        datevalidfromsoft INTEGER,
        datevalidtosoft INTEGER,
        lookaheadforward INTEGER,
        lookaheadside INTEGER,
        deliveryforward INTEGER,
        deliveryside INTEGER,
        routetype TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS streetsummarylist (
        summaryid TEXT PRIMARY KEY,
        jobdetailid TEXT,
        streetname TEXT,
        lat REAL,
        "long" REAL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS addressdetaillist (
        jobdetailid TEXT,
        summaryid TEXT,
        deliveryid TEXT PRIMARY KEY,
        streetaddress TEXT,
        searchaddress TEXT,
        addressnumber TEXT,
        qty INTEGER,
        lat REAL,
        "long" REAL,
        sequence INTEGER,
        jobtype TEXT,
        custsvc TEXT,
        notes TEXT,
        side TEXT,
        photorequired INTEGER
      )
    ''');

    // Load SQL script from assets and execute each statement
    final sqlScript = await rootBundle.loadString('assets/demoRoutes/demo_data.txt');
    final statements = sqlScript.split(';');
    for (var rawStmt in statements) {
      final stmt = rawStmt.trim();
      if (stmt.isNotEmpty) {
        try {
          await db.execute(stmt);
        } catch (e) {
          print('Error executing SQL: $e\nStatement: $stmt');
        }
      }
    }

    // After importing raw data, translate address details into Stops entries
    final addressRows = await db.query('addressdetaillist');
    for (var row in addressRows) {
      try {
        int stopId = int.tryParse(row['deliveryid'].toString()) ?? 0;
        int routeId = int.tryParse(row['jobdetailid'].toString()) ?? 0;
        int sequence = int.tryParse(row['sequence'].toString()) ?? 0;
        String name = row['streetaddress']?.toString() ?? '';
        String address = row['searchaddress']?.toString() ?? '';
        double? lat = row['lat'] != null ? double.tryParse(row['lat'].toString()) : null;
        double? lng = row['long'] != null ? double.tryParse(row['long'].toString()) : null;
        // Create Stop object and insert into Stops table
        Stop stop = Stop(
          id: stopId,
          routeId: routeId,
          sequence: sequence,
          name: name,
          address: address,
          completed: false,
          uploaded: false,
          completedAt: null,
          latitude: lat,
          longitude: lng,
        );
        await db.insert('Stops', stop.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
      } catch (e) {
        print('Error inserting stop from demo data: $e');
      }
    }
  }

  static Future<void> clearAllData() async {
    final db = await _openDatabase();
    await db.delete('Stops'); 
    // Note: If needed, could also clear other tables or reset DB in testing.
  }

  /// Insert a list of stops into the DB (replacing existing ones with the same id).
  static Future<void> insertStops(String routeId, List<Stop> stops) async {
    final db = await _openDatabase();
    for (var s in stops) {
      // Insert or replace stop record
      await db.insert('Stops', s.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  /// Insert a single barcode scan record
  static Future<void> insertBarcodeScan({
    required int stopId,
    required String code,
    required String type,
  }) async {
    final db = await _openDatabase();
    await db.execute('''
      CREATE TABLE IF NOT EXISTS BarcodeScans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        stopId INTEGER,
        code TEXT,
        type TEXT,
        timestamp TEXT
      )
    ''');
    // Insert record
    await db.insert('BarcodeScans', {
      'stopId': stopId,
      'code': code,
      'type': type,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Insert a single photo record
  static Future<void> insertPhoto({
    required int stopId,
    required String filePath,
  }) async {
    final db = await _openDatabase();
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Photos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        stopId INTEGER,
        filePath TEXT,
        timestamp TEXT
      )
    ''');
    await db.insert('Photos', {
      'stopId': stopId,
      'filePath': filePath,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Insert a single signature record
  static Future<void> insertSignature({
    required int stopId,
    required String filePath,
    required String signerName,
  }) async {
    final db = await _openDatabase();
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Signatures (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        stopId INTEGER,
        filePath TEXT,
        signerName TEXT,
        timestamp TEXT
      )
    ''');
    await db.insert('Signatures', {
      'stopId': stopId,
      'filePath': filePath,
      'signerName': signerName,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Mark a stop as delivered (update its completed status in DB)
  static Future<void> updateStopDelivered(Stop stop) async {
    final db = await _openDatabase();
    final updated = {
      'completed': stop.completed ? 1 : 0,
      'uploaded': stop.uploaded ? 1 : 0,
      'completedAt': stop.completedAt?.toIso8601String(),
    };
    await db.update(
      'Stops',
      updated,
      where: 'id = ?',
      whereArgs: [stop.id],
    );
  }

  /// Get stops, optionally filtered by routeId
  static Future<List<Stop>> getStops([String? routeId]) async {
    final db = await _openDatabase();
    String? whereClause;
    List<Object?>? whereArgs;
    if (routeId != null) {
      whereClause = 'routeId = ?';
      whereArgs = [routeId];
    }
    final maps = await db.query('Stops', where: whereClause, whereArgs: whereArgs);
    return maps.map((m) => Stop.fromJson(m)).toList();
  }

  /// Get routes from the routelist table (testing mode)
  static Future<List<RouteModel>> getRoutes() async {
    final db = await _openDatabase();
    final maps = await db.query('routelist');
    return maps.map((m) => RouteModel.fromMap(m)).toList();
  }
}
