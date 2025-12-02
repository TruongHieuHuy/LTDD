import 'package:flutter/material.dart';

/// Gen Z Meme Style Color Palette - Neon chói lóa + Dark mode
class GameColors {
  // === NEON CHÓI LÓA ===
  static const neonYellow = Color(0xFFFFFF00);
  static const neonPink = Color(0xFFFF10F0);
  static const neonCyan = Color(0xFF00FFFF);
  static const neonGreen = Color(0xFF39FF14);
  static const neonOrange = Color(0xFFFF6600);

  // === BACKGROUND TỐI BỤI ===
  static const darkPurple = Color(0xFF1A0033);
  static const darkCharcoal = Color(0xFF0D0D0D);
  static const darkNavy = Color(0xFF0A0E27);
  static const darkGray = Color(0xFF1C1C1E);

  // === ACCENT COLORS ===
  static const trollRed = Color(0xFFFF1744);
  static const successGreen = Color(0xFF00E676);
  static const warningOrange = Color(0xFFFF9800);
  static const infoBlue = Color(0xFF2196F3);

  // === GRADIENT PRESETS ===
  static const LinearGradient neonGradient = LinearGradient(
    colors: [neonPink, neonYellow, neonCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [darkPurple, darkCharcoal],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [successGreen, neonGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient failGradient = LinearGradient(
    colors: [trollRed, Color(0xFFD32F2F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // === TEXT COLORS ===
  static const textWhite = Color(0xFFFFFFFF);
  static const textGray = Color(0xFFB0B0B0);
  static const textDark = Color(0xFF1C1C1E);
}
