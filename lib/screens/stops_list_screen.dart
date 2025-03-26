// lib/screens/stops_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/route_service.dart';
import 'stop_detail_screen.dart';

class StopsListScreen extends StatefulWidget {
  static const routeName = '/stopsList';

  const StopsListScreen({Key? key}) : super(key: key);

  @override
  State<StopsListScreen> createState() => _StopsListScreenState();
}

class _StopsListScreenState extends State<StopsListScreen> {
  @override
  Widget build(BuildContext context) {
    final routeService = context.watch<RouteService>();
    final stops = routeService.stops;
    final selectedRoute = routeService.selectedRoute;

    return Scaffold(
      appBar: AppBar(
        title: Text('Stops - ${selectedRoute?.name ?? ""}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              if (selectedRoute != null) {
                await routeService.fetchStops(selectedRoute.id);
              }
            },
          ),
        ],
      ),
      body: ReorderableListView.builder(
        itemCount: stops.length,
        onReorder: (oldIndex, newIndex) {
          routeService.reorderStops(oldIndex, newIndex);
        },
        itemBuilder: (context, index) {
          final stop = stops[index];
          return ListTile(
            key: ValueKey(stop.id),
            title: Text(stop.address),
            subtitle: Text('Completed: ${stop.completed ? "Yes" : "No"}'),
            trailing: Icon(
              stop.completed ? Icons.check_circle : Icons.radio_button_unchecked,
              color: stop.completed ? Colors.green : null,
            ),
            onTap: () {
              Navigator.pushNamed(context, StopDetailScreen.routeName,
                  arguments: stop.id);
            },
          );
        },
      ),
    );
  }
}
