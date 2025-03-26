// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/app_state.dart';
import 'login_screen.dart';
import 'route_select_screen.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/splash';

  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // Try to load saved token
    await AuthService.loadSavedToken();

    final appState = context.read<AppState>();
    // If we want to see if user is still valid, we can attempt
    // some check or a "getProfile" call, but let's keep it simple:
    if (appState.isLoggedIn) {
      // If we had user data cached, we might skip directly
      _goToRouteSelect();
    } else {
      // else go to login
      _goToLogin();
    }
  }

  void _goToLogin() {
    Navigator.pushReplacementNamed(context, LoginScreen.routeName);
  }

  void _goToRouteSelect() {
    Navigator.pushReplacementNamed(context, RouteSelectScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
