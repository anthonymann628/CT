// lib/services/delivery_service.dart
import 'package:flutter/foundation.dart';

import '../models/stop.dart';
import 'api_client.dart'; // if you have an ApiClient, or remove if not
import 'database_service.dart';

class DeliveryService extends ChangeNotifier {
  Future<void> attachBarcode(Stop stop, String code) async {
    // add code to stop barcodes
    stop.barcodes.add(code);
    notifyListeners();
  }

  Future<void> attachPhoto(Stop stop, String photoPath) async {
    stop.photoPath = photoPath;
    notifyListeners();
  }

  Future<void> attachSignature(Stop stop, String signaturePath) async {
    stop.signaturePath = signaturePath;
    notifyListeners();
  }

  Future<void> completeStop(Stop stop) async {
    // Mark stop completed
    stop.completed = true;
    stop.completedAt = DateTime.now();
    try {
      await _uploadStop(stop);
      stop.uploaded = true;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading stop: $e');
      }
    }
    notifyListeners();
  }

  Future<void> _uploadStop(Stop stop) async {
    // If you have an actual API for uploading stops
    final payload = stop.toMap(); // using toMap
    // Possibly do an ApiClient post
    // Example: await ApiClient.post('/stops/${stop.id}/complete', payload);
    // or store it locally
    await DatabaseService.updateStopDelivered(stop);
  }
}
