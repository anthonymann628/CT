import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/route_select_screen.dart';
import 'screens/stops_list_screen.dart';
import 'screens/stop_detail_screen.dart';
import 'screens/device_status_screen.dart';
import 'screens/manual_sync_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/log_viewer_screen.dart';
import 'screens/tools_screen.dart';
import 'screens/camera_screen.dart';
import 'screens/signature_screen.dart';
import 'screens/barcode_scanner_screen.dart';
// Services
import 'services/app_state.dart';
import 'services/route_service.dart';
import 'services/delivery_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => RouteService()),
        ChangeNotifierProvider(create: (_) => DeliveryService()),
        // Add any other services to provide if needed
      ],
      child: const CarrierTrackApp(),
    ),
  );
}

class CarrierTrackApp extends StatelessWidget {
  const CarrierTrackApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CarrierTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (ctx) => const SplashScreen(),
        LoginScreen.routeName: (ctx) => const LoginScreen(),
        RouteSelectScreen.routeName: (ctx) => const RouteSelectScreen(),
        StopsListScreen.routeName: (ctx) => const StopsListScreen(),
        StopDetailScreen.routeName: (ctx) => const StopDetailScreen(),
        DeviceStatusScreen.routeName: (ctx) => const DeviceStatusScreen(),
        ManualSyncScreen.routeName: (ctx) => const ManualSyncScreen(),
        SettingsScreen.routeName: (ctx) => const SettingsScreen(),
        LogViewerScreen.routeName: (ctx) => const LogViewerScreen(),
        ToolsScreen.routeName: (ctx) => const ToolsScreen(),
        CameraScreen.routeName: (ctx) => const CameraScreen(),
        SignatureScreen.routeName: (ctx) => const SignatureScreen(),
        BarcodeScannerScreen.routeName: (ctx) => const BarcodeScannerScreen(),
      },
    );
  }
}
