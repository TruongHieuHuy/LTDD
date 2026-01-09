import 'package:flutter/material.dart';
import '../config/gaming_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GamingTheme.primaryDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Gaming logo/icon
            Icon(
              Icons.sports_esports,
              size: 100,
              color: GamingTheme.primaryAccent,
            ),
            const SizedBox(height: 24),
            Text(
              'MiniGameCenter',
              style: GamingTheme.h1.copyWith(
                fontSize: 32,
                color: GamingTheme.primaryAccent,
              ),
            ),
            const SizedBox(height: 48),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(GamingTheme.primaryAccent),
            ),
          ],
        ),
      ),
    );
  }
}
