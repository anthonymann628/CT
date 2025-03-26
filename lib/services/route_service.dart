// lib/services/route_service.dart

import 'package:flutter/foundation.dart';

import '../config.dart'; // <-- import this so 'Config' is recognized
import '../models/route.dart';
import '../models/stop.dart';
import 'database_service.dart';

class RouteService extends ChangeNotifier {
  List<RouteModel> _routes = [];
  RouteModel? _selectedRoute;
  List<Stop> _stops = [];

  List<RouteModel> get routes => _routes;
  RouteModel? get selectedRoute => _selectedRoute;
  List<Stop> get stops => _stops;

  Future<void> fetchRoutes() async {
    if (Config.isTesting) {
      await DatabaseService.importDemoData();
      _routes = await DatabaseService.getRoutes();
      notifyListeners();
    } else {
      // production
      _routes = [];
      notifyListeners();
    }
  }

  Future<void> selectRoute(RouteModel route) async {
    _selectedRoute = route;
    notifyListeners();
    await fetchStops(route.id);
  }

  Future<void> fetchStops(String routeId) async {
    if (Config.isTesting) {
      _stops = await DatabaseService.getStops(routeId);
      notifyListeners();
    } else {
      // production
      _stops = [];
      notifyListeners();
    }
  }

  void reorderStops(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final item = _stops.removeAt(oldIndex);
    _stops.insert(newIndex, item);
    notifyListeners();
  }
}
