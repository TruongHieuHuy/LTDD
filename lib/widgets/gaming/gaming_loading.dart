import 'package:flutter/material.dart';
import '../../config/gaming_theme.dart';

/// Gaming-themed loading indicator
class GamingLoading extends StatelessWidget {
  final String? message;
  final double size;

  const GamingLoading({
    super.key,
    this.message,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: const AlwaysStoppedAnimation<Color>(
                GamingTheme.primaryAccent,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: GamingTheme.m),
            Text(
              message!,
              style: GamingTheme.bodyMedium.copyWith(
                color: GamingTheme.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Gaming-themed loading overlay
class GamingLoadingOverlay extends StatelessWidget {
  final String? message;

  const GamingLoadingOverlay({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: GamingTheme.primaryDark.withOpacity(0.8),
      child: GamingLoading(message: message),
    );
  }
}
