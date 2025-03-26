// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/app_state.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/route_select_screen.dart';
import 'screens/home_screen.dart';
import 'screens/route_details_screen.dart';

void main() {
  runApp(const CarrierTrackApp());
}

class CarrierTrackApp extends StatelessWidget {
  const CarrierTrackApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provide a single global AppState for the app
        ChangeNotifierProvider(create: (_) => AppState()),
        // You can add other providers here if needed
      ],
      child: MaterialApp(
        title: 'CarrierTrack',
        debugShowCheckedModeBanner: false,
        // Start at splash screen
        initialRoute: SplashScreen.routeName,
        routes: {
          SplashScreen.routeName: (ctx) => const SplashScreen(),
          LoginScreen.routeName: (ctx) => const LoginScreen(),
          RouteSelectScreen.routeName: (ctx) => const RouteSelectScreen(),
          HomeScreen.routeName: (ctx) => const HomeScreen(),
          RouteDetailsScreen.routeName: (ctx) => const RouteDetailsScreen(),
          // Add other screens as needed
        },
      ),
    );
  }
}
