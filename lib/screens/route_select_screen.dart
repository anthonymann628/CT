// lib/screens/route_select_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/route_service.dart';
import '../models/route.dart';
import 'stops_list_screen.dart';

class RouteSelectScreen extends StatefulWidget {
  static const routeName = '/routeSelect';

  const RouteSelectScreen({Key? key}) : super(key: key);

  @override
  State<RouteSelectScreen> createState() => _RouteSelectScreenState();
}

class _RouteSelectScreenState extends State<RouteSelectScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchRoutes();
  }

  Future<void> _fetchRoutes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await context.read<RouteService>().fetchRoutes();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching routes: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectRoute(RouteModel route) async {
    try {
      await context.read<RouteService>().selectRoute(route);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, StopsListScreen.routeName);
    } catch (e) {
      setState(() => _errorMessage = 'Failed to select route: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final routeService = context.watch<RouteService>();
    final routes = routeService.routes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Route'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : ListView.builder(
                  itemCount: routes.length,
                  itemBuilder: (context, index) {
                    final route = routes[index];
                    return ListTile(
                      title: Text(route.name),
                      subtitle: Text(route.date ?? ''),
                      onTap: () => _selectRoute(route),
                    );
                  },
                ),
    );
  }
}
