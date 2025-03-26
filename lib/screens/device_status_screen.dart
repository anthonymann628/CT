// lib/screens/device_status_screen.dart
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';

class DeviceStatusScreen extends StatefulWidget {
  static const routeName = '/deviceStatus';

  const DeviceStatusScreen({Key? key}) : super(key: key);

  @override
  State<DeviceStatusScreen> createState() => _DeviceStatusScreenState();
}

class _DeviceStatusScreenState extends State<DeviceStatusScreen> {
  String _connectionStatus = 'Unknown';
  String _locationStatus = 'Unknown';
  String _batteryStatus = 'Unknown';

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _checkLocation();
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      if (connectivityResult == ConnectivityResult.mobile) {
        _connectionStatus = 'Mobile Data';
      } else if (connectivityResult == ConnectivityResult.wifi) {
        _connectionStatus = 'Wi-Fi';
      } else {
        _connectionStatus = 'No network';
      }
    });
  }

  Future<void> _checkLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _locationStatus = 'Location Service Off');
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() => _locationStatus = 'Location Permission Denied');
      return;
    }
    // If permission granted
    final pos = await Geolocator.getCurrentPosition();
    setState(() => _locationStatus = 'Lat: ${pos.latitude}, Lng: ${pos.longitude}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Status'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Connectivity: $_connectionStatus'),
            const SizedBox(height: 8),
            Text('Location: $_locationStatus'),
            const SizedBox(height: 8),
            Text('Battery: $_batteryStatus'),
          ],
        ),
      ),
    );
  }
}
