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
  // If routeId can be int or string
  // We'll store an int for now
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
  });

  factory Stop.fromJson(Map<String, dynamic> json) {
    return Stop(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      routeId: json['routeId'] is int
          ? json['routeId']
          : int.tryParse(json['routeId']?.toString() ?? '0') ?? 0,
      sequence: json['sequence'] is int ? json['sequence'] : 0,
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      completed: (json['completed'] == 1 || json['completed'] == true),
      uploaded: (json['uploaded'] == 1 || json['uploaded'] == true),
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'].toString())
          : null,
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'routeId': routeId,
      'sequence': sequence,
      'name': name,
      'address': address,
      'completed': completed ? 1 : 0,
      'uploaded': uploaded ? 1 : 0,
      'completedAt': completedAt?.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
