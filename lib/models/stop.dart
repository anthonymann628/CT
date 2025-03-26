// lib/models/stop.dart
class Stop {
  final String id;          // unique stop ID (string for consistency)
  final String routeId;     // route ID this stop belongs to
  final String name;        // name or label of the stop
  final String address;
  double? latitude;
  double? longitude;
  int sequence;
  bool completed;           // whether stop delivery is completed (was "delivered")
  bool uploaded;            // whether stop data is synced/uploaded (was "synced")
  List<String> barcodes;    // list of barcode values scanned
  String? photoPath;        // file path of the proof photo (if any)
  String? signaturePath;    // file path of the signature image (if any)
  DateTime? completedAt;    // timestamp when completed (deliveredAt in DB)

  Stop({
    required this.id,
    required this.routeId,
    required this.name,
    required this.address,
    this.latitude,
    this.longitude,
    this.sequence = 0,
    this.completed = false,
    this.uploaded = false,
    List<String>? barcodes,
    this.photoPath,
    this.signaturePath,
    this.completedAt,
  }) : barcodes = barcodes ?? [];

  /// Construct from API JSON
  factory Stop.fromJson(Map<String, dynamic> json) {
    return Stop(
      id: json['id'].toString(),
      routeId: json['routeId']?.toString() ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      latitude: json['latitude'] != null 
          ? double.tryParse(json['latitude'].toString()) 
          : null,
      longitude: json['longitude'] != null 
          ? double.tryParse(json['longitude'].toString()) 
          : null,
      sequence: json['sequence'] ?? 0,
      completed: json['completed'] ?? false, 
      uploaded: json['uploaded'] ?? false,
      barcodes: (json['barcodes'] as List?)?.map((e) => e.toString()).toList() ?? [],
      photoPath: json['photoPath'],
      signaturePath: json['signaturePath'],
      completedAt: json['completedAt'] != null 
          ? DateTime.tryParse(json['completedAt'])
          : null,
    );
  }

  /// Construct from DB map. Our DB columns are named 'delivered' for completed,
  /// and 'deliveredAt' for completedAt, so we convert them accordingly.
  factory Stop.fromMap(Map<String, dynamic> map) {
    return Stop(
      id: map['id'].toString(),
      routeId: map['routeId'].toString(),
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      latitude: map['latitude'] != null
          ? (map['latitude'] as num).toDouble()
          : null,
      longitude: map['longitude'] != null
          ? (map['longitude'] as num).toDouble()
          : null,
      sequence: map['sequence'] as int? ?? 0,
      completed: (map['delivered'] ?? 0) == 1,  // DB uses 'delivered'
      uploaded: (map['synced'] ?? 0) == 1,      // DB uses 'synced'
      // barcodes, photos, signatures are attached later by DatabaseService.getStops
      barcodes: [],
      photoPath: null,
      signaturePath: null,
      completedAt: map['deliveredAt'] != null
          ? DateTime.tryParse(map['deliveredAt'])
          : null,
    );
  }

  /// Convert Stop to Map for DB insertion
  Map<String, dynamic> toMap() {
    return {
      // Attempt to store id, routeId as int if numeric
      'id': int.tryParse(id) ?? id,
      'routeId': int.tryParse(routeId) ?? routeId,
      'sequence': sequence,
      'name': name,
      'address': address,
      // Our DB columns are named 'delivered' and 'synced' but we use 'completed', 'uploaded' in code
      'delivered': completed ? 1 : 0,
      'synced': uploaded ? 1 : 0,
      'deliveredAt': completedAt?.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  bool get isFullyComplete {
    // Example logic: require at least one barcode, a photo, and a signature if completed
    if (!completed) return false;
    return barcodes.isNotEmpty && photoPath != null && signaturePath != null;
  }
}
