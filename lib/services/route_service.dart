// lib/services/route_service.dart

import 'package:flutter/foundation.dart';

import '../config.dart';
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
      // Load from local DB after import
      await DatabaseService.importDemoData();
      _routes = []; // We'll ignore the 'demo_data.txt' specifics or table names
      // If you do want to parse them from a table, do so:
      // final routeStops = await DatabaseService.getStops();
      // Or if you have a separate 'getRoutes()' method in DB:
      // _routes = await DatabaseService.getRoutes();
      notifyListeners();
    } else {
      // Non-testing: replace with real network call or do nothing
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
      // Load from local DB
      _stops = await DatabaseService.getStops(routeId);
      notifyListeners();
    } else {
      // Non-testing
      _stops = [];
      notifyListeners();
    }
  }
}
