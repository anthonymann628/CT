// lib/screens/stop_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/route_service.dart';
import '../services/delivery_service.dart';
import '../models/stop.dart';
import 'barcode_scanner_screen.dart';
import 'camera_screen.dart';
import 'signature_screen.dart';

class StopDetailScreen extends StatefulWidget {
  static const routeName = '/stopDetail';

  const StopDetailScreen({Key? key}) : super(key: key);

  @override
  State<StopDetailScreen> createState() => _StopDetailScreenState();
}

class _StopDetailScreenState extends State<StopDetailScreen> {
  Stop? _stop;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final stopId = ModalRoute.of(context)?.settings.arguments as String?;
    if (stopId != null) {
      final routeService = context.read<RouteService>();
      _stop = routeService.stops.firstWhere((s) => s.id == stopId);
    }
  }

  Future<void> _scanBarcode() async {
    if (_stop == null) return;
    // Push the scanner screen
    final code = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );
    if (code != null) {
      await context.read<DeliveryService>().attachBarcode(_stop!, code);
      setState(() {});
    }
  }

  Future<void> _takePhoto() async {
    if (_stop == null) return;
    // Go to camera
    final photoPath = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const CameraScreen()),
    );
    if (photoPath != null) {
      await context.read<DeliveryService>().attachPhoto(_stop!, photoPath);
      setState(() {});
    }
  }

  Future<void> _captureSignature() async {
    if (_stop == null) return;
    final signaturePath = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const SignatureScreen()),
    );
    if (signaturePath != null) {
      await context.read<DeliveryService>().attachSignature(_stop!, signaturePath);
      setState(() {});
    }
  }

  Future<void> _completeStop() async {
    if (_stop == null) return;
    await context.read<DeliveryService>().completeStop(_stop!);
    Navigator.pop(context); // back to stops list
  }

  @override
  Widget build(BuildContext context) {
    if (_stop == null) {
      return const Scaffold(body: Center(child: Text('Stop not found')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Stop: ${_stop!.address}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Address: ${_stop!.address}'),
            const SizedBox(height: 8),
            Text('Scanned Barcodes: ${_stop!.barcodes.join(', ')}'),
            const SizedBox(height: 8),
            Text(_stop!.photoPath == null ? 'No Photo' : 'Photo: ${_stop!.photoPath}'),
            const SizedBox(height: 8),
            Text(_stop!.signaturePath == null
                ? 'No Signature'
                : 'Signature: ${_stop!.signaturePath}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _scanBarcode,
              child: const Text('Scan Barcode'),
            ),
            ElevatedButton(
              onPressed: _takePhoto,
              child: const Text('Take Photo'),
            ),
            ElevatedButton(
              onPressed: _captureSignature,
              child: const Text('Capture Signature'),
            ),
            const Divider(),
            ElevatedButton(
              onPressed: _stop!.completed ? null : _completeStop,
              child: const Text('Complete Stop'),
            ),
          ],
        ),
      ),
    );
  }
}
