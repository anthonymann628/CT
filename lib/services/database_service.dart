// lib/services/database_service.dart
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/stop.dart';
import '../models/barcode_scan.dart';
import '../models/photo.dart';
import '../models/signature.dart';
import '../utils/constants.dart';

class DatabaseService {
  static Database? _db;
  
  static Future<void> executeRawSql(String sql) async {
  final db = await _getDatabase();
  await db.execute(sql);
  }

  static Future<Database> _getDatabase() async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, Constants.dbName);
    _db = await openDatabase(path, version: Constants.dbVersion, onCreate: (db, version) async {
      // Create tables
      await db.execute('''
        CREATE TABLE stops (
          id INTEGER PRIMARY KEY,
          routeId INTEGER,
          sequence INTEGER,
          name TEXT,
          address TEXT,
          delivered INTEGER,
          synced INTEGER,
          deliveredAt TEXT,
          latitude REAL,
          longitude REAL
        )
      ''');
      await db.execute('''
        CREATE TABLE barcode_scans (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          routeId INTEGER,
          stopId INTEGER,
          code TEXT,
          type TEXT,
          timestamp TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE photos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          routeId INTEGER,
          stopId INTEGER,
          filePath TEXT,
          timestamp TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE signatures (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          routeId INTEGER,
          stopId INTEGER,
          filePath TEXT,
          signerName TEXT,
          timestamp TEXT
        )
      ''');
    });
    return _db!;
  }

  static Future<void> clearAllData() async {
    final db = await _getDatabase();
    await db.delete('barcode_scans');
    await db.delete('photos');
    await db.delete('signatures');
    await db.delete('stops');
  }

  static Future<void> insertStops(List<Stop> stops) async {
    final db = await _getDatabase();
    Batch batch = db.batch();
    for (Stop stop in stops) {
      batch.insert('stops', stop.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  static Future<List<Stop>> getStops() async {
    final db = await _getDatabase();
    final stopMaps = await db.query('stops');
    List<Stop> stops = stopMaps.map((m) => Stop.fromMap(m)).toList();
    if (stops.isEmpty) return [];

    // Fetch related data and attach to stops
    final scanMaps = await db.query('barcode_scans');
    final photoMaps = await db.query('photos');
    final signatureMaps = await db.query('signatures');

    // Index stops by id for quick lookup
    final stopById = { for (var s in stops) s.id: s };

    // Attach barcode scans
    for (var m in scanMaps) {
      BarcodeScan scan = BarcodeScan.fromMap(m);
      String? sid = m['stopId']?.toString();
      if (sid != null && stopById.containsKey(sid)) {
        // Add the code to the stop's barcode list
        stopById[sid]!.barcodes.add(scan.code);
      }
    }
    // Attach photos
    for (var m in photoMaps) {
      Photo photo = Photo.fromMap(m);
      String? sid = m['stopId']?.toString();
      if (sid != null && stopById.containsKey(sid)) {
        // If multiple photos, we take the latest one for photoPath (or extend model to list if needed)
        stopById[sid]!.photoPath = photo.filePath;
        // (If needed, you could maintain a list of photos; but our Stop uses single photoPath for simplicity)
      }
    }
    // Attach signatures
    for (var m in signatureMaps) {
      Signature sig = Signature.fromMap(m);
      String? sid = m['stopId']?.toString();
      if (sid != null && stopById.containsKey(sid)) {
        stopById[sid]!.signaturePath = sig.filePath;
        // (We don't store signerName in Stop, but could if needed)
      }
    }

    return stops;
  }

  static Future<void> insertBarcodeScan(BarcodeScan scan) async {
    final db = await _getDatabase();
    await db.insert('barcode_scans', scan.toMap());
  }

  static Future<void> insertPhoto(Photo photo) async {
    final db = await _getDatabase();
    await db.insert('photos', photo.toMap());
  }

  static Future<void> insertSignature(Signature signature) async {
    final db = await _getDatabase();
    await db.insert('signatures', signature.toMap());
  }

  static Future<void> updateStopDelivered(Stop stop) async {
    final db = await _getDatabase();
    await db.update(
      'stops',
      {
        'delivered': stop.completed ? 1 : 0,
        'deliveredAt': stop.completedAt?.toIso8601String(),
        'latitude': stop.latitude,
        'longitude': stop.longitude,
        'synced': stop.uploaded ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [int.tryParse(stop.id) ?? stop.id],
    );
  }
}
