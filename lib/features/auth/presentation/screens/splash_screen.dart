import 'package:blood_donation/core/network/api_client.dart';
import 'package:blood_donation/core/services/token_storage.dart';
import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:blood_donation/features/auth/presentation/screens/login_screen.dart';
import 'package:blood_donation/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:blood_donation/features/home/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    // First launch — show onboarding
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_done') ?? false;
    if (!onboardingDone) {
      _go(const OnboardingScreen());
      return;
    }

    // Already onboarded — check token
    final hasToken = await TokenStorage.instance.hasToken();
    if (!hasToken) {
      _go(const LoginScreen());
      return;
    }

    // Try silent token refresh
    final refreshed = await const ApiClient().tryRefreshToken();
    if (!mounted) return;

    if (refreshed) {
      _go(const HomeScreen());
    } else {
      await TokenStorage.instance.clearTokens();
      _go(const LoginScreen());
    }
  }

  void _go(Widget screen) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.red,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite,
                  color: Colors.white, size: 56),
            ),
            const SizedBox(height: 24),
            const Text(
              'Blood Donation',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Save lives. Every drop counts.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}