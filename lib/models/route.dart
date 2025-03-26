class RouteModel {
  final String id;
  final String name;
  final String? date;

  RouteModel({required this.id, required this.name, this.date});

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    // Parse API JSON into RouteModel
    String idStr = json['id']?.toString() ?? '';
    String nameStr = json['name']?.toString() ?? '';
    String? dateStr;
    if (json.containsKey('date')) {
      dateStr = json['date']?.toString();
    } else if (json.containsKey('dateValidFrom')) {
      // If API uses different keys for date range
      final ts = int.tryParse(json['dateValidFrom']?.toString() ?? '');
      if (ts != null) {
        dateStr = _formatDate(ts);
      }
    }
    return RouteModel(id: idStr, name: nameStr, date: dateStr);
  }

  // Construct from local database record (routelist table)
  factory RouteModel.fromMap(Map<String, dynamic> map) {
    // The routelist table stores jobdetailid (int), routeid (code), city, state, and date range.
    String routeCode = map['routeid']?.toString() ?? '';
    int jobDetailId = (map['jobdetailid'] is int) 
        ? map['jobdetailid'] 
        : int.tryParse(map['jobdetailid']?.toString() ?? '0') ?? 0;
    String city = map['city']?.toString() ?? '';
    String state = map['state']?.toString() ?? '';
    // Format name as "<RouteCode> - <City>, <State>"
    String nameStr = routeCode.isNotEmpty ? '$routeCode - $city, $state' : '$city, $state';
    // Parse date range start into a readable date (e.g., MM/dd/yyyy)
    String? dateStr;
    if (map['datevalidfrom'] != null) {
      int ts = (map['datevalidfrom'] is int) 
          ? map['datevalidfrom'] 
          : int.tryParse(map['datevalidfrom'].toString()) ?? 0;
      if (ts > 0) {
        dateStr = _formatDate(ts);
      }
    }
    return RouteModel(id: jobDetailId.toString(), name: nameStr, date: dateStr);
  }

  static String _formatDate(int epochSeconds) {
    // Convert epoch seconds to DateTime and format as "MM/dd/yyyy"
    final dt = DateTime.fromMillisecondsSinceEpoch(epochSeconds * 1000, isUtc: true).toLocal();
    return '${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}/${dt.year}';
  }
}
