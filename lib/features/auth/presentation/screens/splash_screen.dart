import 'package:blood_donation/core/network/api_client.dart';
import 'package:blood_donation/core/services/token_storage.dart';
import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:blood_donation/features/auth/presentation/screens/login_screen.dart';
import 'package:blood_donation/features/home/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';

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

    final hasToken = await TokenStorage.instance.hasToken();

    if (!hasToken) {
      _goToLogin();
      return;
    }

    // Silently refresh the token on startup to ensure it's still valid.
    // If the refresh token is also expired, force re-login.
    final refreshed = await const ApiClient().tryRefreshToken();

    if (!mounted) return;

    if (refreshed) {
      _goToHome();
    } else {
      // Both tokens expired — clear storage and go to login
      await TokenStorage.instance.clearTokens();
      _goToLogin();
    }
  }

  void _goToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
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
                color: AppTheme.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite,
                color: AppTheme.white,
                size: 56,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Blood Donation',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Save lives. Every drop counts.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.white.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: AppTheme.white,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}