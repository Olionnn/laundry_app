import 'package:flutter/material.dart';
import 'package:laundry_app/services/auth_services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    try {
      final isValid = await authService.checkToken();
      if (isValid) {
        // If the token is valid, navigate to requestLayanan
        Navigator.pushReplacementNamed(context, AppRoutes.requestLayanan);
      } else {
        // If the token is invalid, navigate to login
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } catch (e) {
      // On error, navigate to login
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              'Loading...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
