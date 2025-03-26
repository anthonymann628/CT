// lib/services/route_service.dart
import 'package:flutter/foundation.dart';
import '../models/route.dart';
import '../models/stop.dart';
import 'api_client.dart';

class RouteService extends ChangeNotifier {
  List<RouteModel> _routes = [];
  RouteModel? _selectedRoute;
  List<Stop> _stops = [];

  List<RouteModel> get routes => _routes;
  RouteModel? get selectedRoute => _selectedRoute;
  List<Stop> get stops => _stops;

  Future<void> fetchRoutes() async {
    final data = await ApiClient.get('/routes');
    final list = data as List;
    _routes = list.map((json) => RouteModel.fromJson(json)).toList();
    notifyListeners();
  }

  Future<void> selectRoute(RouteModel route) async {
    _selectedRoute = route;
    notifyListeners();
    await fetchStops(route.id);
  }

  Future<void> fetchStops(String routeId) async {
    final data = await ApiClient.get('/routes/$routeId/stops');
    final list = data as List;
    _stops = list.map((json) => Stop.fromJson(json)).toList();
    notifyListeners();
  }

  void reorderStops(int oldIndex, int newIndex) {
    if (newIndex > _stops.length) newIndex = _stops.length;
    if (oldIndex < newIndex) {
      newIndex--;
    }
    final item = _stops.removeAt(oldIndex);
    _stops.insert(newIndex, item);
    // re-sequence them
    for (var i = 0; i < _stops.length; i++) {
      _stops[i].sequence = i;
    }
    notifyListeners();
    // Possibly call an API to save the new order
  }
}
