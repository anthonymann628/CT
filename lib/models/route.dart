// lib/models/route.dart
class RouteModel {
  final String id;
  final String name;
  final String? date; // optional if your API returns a date

  RouteModel({
    required this.id,
    required this.name,
    this.date,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      date: json['date'],
    );
  }
}
