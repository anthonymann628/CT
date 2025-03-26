// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings';

  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _vibrateOnScan = true; // example setting
  bool _keepScreenOn = false; // example setting

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Vibrate on Scan'),
            value: _vibrateOnScan,
            onChanged: (val) {
              setState(() => _vibrateOnScan = val);
              // TODO: save to SharedPreferences or something
            },
          ),
          SwitchListTile(
            title: const Text('Keep Screen On'),
            value: _keepScreenOn,
            onChanged: (val) {
              setState(() => _keepScreenOn = val);
              // For keep screen awake, you can use wakelock plugin
            },
          ),
        ],
      ),
    );
  }
}
