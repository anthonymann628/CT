// lib/screens/route_details_screen.dart

import 'package:flutter/material.dart';
import '../models/stop.dart';
import '../services/database_service.dart';
import '../services/sync_service.dart';

class RouteDetailsScreen extends StatefulWidget {
  static const routeName = '/routeDetails';

  const RouteDetailsScreen({Key? key}) : super(key: key);

  @override
  _RouteDetailsScreenState createState() => _RouteDetailsScreenState();
}

class _RouteDetailsScreenState extends State<RouteDetailsScreen> {
  bool _processing = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    // We assume you have stops passed in, or you could fetch them from a provider
    final List<Stop> stops = ModalRoute.of(context)!.settings.arguments as List<Stop>? ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Details'),
      ),
      body: _processing
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: stops.length,
              itemBuilder: (context, index) {
                final stop = stops[index];
                return ListTile(
                  title: Text(stop.name),
                  subtitle: Text(stop.address),
                  onTap: () => _completeStop(stop),
                );
              },
            ),
    );
  }

  Future<void> _completeStop(Stop stop) async {
    if (_processing) return;
    setState(() => _processing = true);

    try {
      // insert a dummy barcode scan
      await DatabaseService.insertBarcodeScan(
        stopId: stop.id,
        code: 'TEST123',
        type: 'QR',
      );
      // insert a dummy photo
      await DatabaseService.insertPhoto(
        stopId: stop.id,
        filePath: '/path/to/photo.jpg',
      );
      // insert a dummy signature
      await DatabaseService.insertSignature(
        stopId: stop.id,
        filePath: '/path/to/signature.png',
        signerName: 'John Doe',
      );

      // Mark stop as completed
      stop.completed = true;
      stop.completedAt = DateTime.now();
      // Update local DB
      await DatabaseService.updateStopDelivered(stop);

      // Attempt immediate sync
      await SyncService.syncStopData(stop);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stop #${stop.id} completed.')),
      );
    } catch (e) {
      setState(() => _error = 'Failed to complete stop: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_error!)),
      );
    } finally {
      setState(() => _processing = false);
    }
  }
}
