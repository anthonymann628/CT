// lib/models/stop.dart

class Stop {
  int id;
  bool completed;
  bool uploaded;
  DateTime? completedAt;
  double? latitude;
  double? longitude;
  int sequence;
  String name;
  String address;
  List<String> barcodes = [];
  String? photoPath;
  String? signaturePath;
  int routeId;

  Stop({
    required this.id,
    required this.routeId,
    required this.sequence,
    required this.name,
    required this.address,
    this.completed = false,
    this.uploaded = false,
    this.completedAt,
    this.latitude,
    this.longitude,
    this.barcodes = const [],
    this.photoPath,
    this.signaturePath,
  });

  factory Stop.fromJson(Map<String, dynamic> json) {
    return Stop(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      routeId: json['routeId'] is int
          ? json['routeId']
          : int.tryParse(json['routeId']?.toString() ?? '0') ?? 0,
      sequence: json['sequence'] is int
          ? json['sequence']
          : int.tryParse(json['sequence']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      completed: (json['completed'] == 1 || json['completed'] == true),
      uploaded: (json['uploaded'] == 1 || json['uploaded'] == true),
      completedAt: (json['completedAt'] != null)
          ? DateTime.tryParse(json['completedAt'].toString())
          : null,
      latitude: (json['latitude'] != null)
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: (json['longitude'] != null)
          ? double.tryParse(json['longitude'].toString())
          : null,
      barcodes: (json['barcodes'] is List)
          ? List<String>.from(json['barcodes'])
          : <String>[],
      photoPath: json['photoPath']?.toString(),
      signaturePath: json['signaturePath']?.toString(),
    );
  }

  /// Some code calls `toMap()`. We provide it here:
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'routeId': routeId.toString(),
      'sequence': sequence,
      'name': name,
      'address': address,
      'completed': completed ? 1 : 0,
      'uploaded': uploaded ? 1 : 0,
      'completedAt': completedAt?.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      // barcodes, photoPath, signaturePath are not included in DB 'Stops' table
    };
  }

  /// If needed for JSON serialization
  Map<String, dynamic> toJson() => toMap();
}
