// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';           // <-- import the real user model
import '../services/auth_service.dart';
import '../services/app_state.dart';
import 'route_select_screen.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _doLogin() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final username = _userCtrl.text.trim();
    final password = _passCtrl.text.trim();

    // SPECIAL CHECK: If username is empty and password == 'test', skip normal login
    if (username.isEmpty && password == 'test') {
      final user = User(username: 'DemoUser', token: 'testToken');
      context.read<AppState>().setUser(user);
      Navigator.pushReplacementNamed(context, RouteSelectScreen.routeName);

      setState(() => _isLoading = false);
      return;
    }

    try {
      final user = await AuthService.login(username, password);
      if (user == null) {
        setState(() => _error = 'Invalid credentials');
      } else {
        context.read<AppState>().setUser(user);
        Navigator.pushReplacementNamed(context, RouteSelectScreen.routeName);
      }
    } catch (e) {
      setState(() => _error = 'Login failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CarrierTrack - Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            TextField(
              controller: _userCtrl,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passCtrl,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _doLogin,
                    child: const Text('Log In'),
                  ),
          ],
        ),
      ),
    );
  }
}
