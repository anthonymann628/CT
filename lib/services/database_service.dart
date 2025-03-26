// lib/services/database_service.dart

import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/stop.dart';

class DatabaseService {
  static Database? _db;

  static Future<Database> _openDatabase() async {
    if (_db != null) return _db!;
    final databasesPath = await getDatabasesPath();
    final dbPath = p.join(databasesPath, 'ctfo_demo.db');
    _db = await openDatabase(dbPath, version: 1, onCreate: (db, version) async {
      // Basic onCreate if needed
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

      // Similarly define tables for Photos, Signatures, BarcodeScan, etc. if needed
    });
    return _db!;
  }

  /// For the fallback demo data. We'll just run all the commands in the file.
  static Future<void> importDemoData() async {
    final db = await _openDatabase();
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
  }

  static Future<void> clearAllData() async {
    final db = await _openDatabase();
    await db.delete('Stops'); // Clear the 'Stops' table
    // If your demo_data uses different table names, also clear them if you want
  }

  /// Insert a list of stops into DB
  static Future<void> insertStops(String routeId, List<Stop> stops) async {
    final db = await _openDatabase();
    for (var s in stops) {
      // If you need routeId explicitly, set it
      s.routeIdString = routeId;
      await db.insert('Stops', s.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  /// Insert a single barcode scan record (dummy example)
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

  /// Mark a stop as delivered
  static Future<void> updateStopDelivered(Stop stop) async {
    final db = await _openDatabase();
    // Convert booleans to int
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
}
