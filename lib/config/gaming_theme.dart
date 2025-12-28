import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Gaming Hub Theme - Cyber Gaming Center
/// Modern dark theme with neon accents for premium gaming experience
class GamingTheme {
  // ==================== COLORS ====================
  
  /// Primary Colors - Dark Base
  static const Color primaryDark = Color(0xFF0A0E27);      // Navy Black background
  static const Color surfaceDark = Color(0xFF1A1D3F);      // Card/Modal surface
  static const Color surfaceLight = Color(0xFF2D3159);     // Hover states
  
  /// Accent Colors - Neon
  static const Color primaryAccent = Color(0xFF00D9FF);    // Electric Cyan - CTAs
  static const Color secondaryAccent = Color(0xFFFF006E);  // Magenta Neon - Alerts
  static const Color tertiaryAccent = Color(0xFF7B2CBF);   // Purple - Premium
  
  /// Game Difficulty Colors (Neon)
  static const Color easyGreen = Color(0xFF7DFF7D);        // Easy mode
  static const Color mediumOrange = Color(0xFFFFB347);     // Medium mode
  static const Color hardRed = Color(0xFFFF4D4D);          // Hard mode
  static const Color expertPurple = Color(0xFFB54FFF);     // Expert mode
  
  /// Achievement Rarity Colors
  static const Color commonGray = Color(0xFFB0B0B0);
  static const Color rareBlue = Color(0xFF4A90E2);
  static const Color epicPurple = Color(0xFF9B59B6);
  static const Color legendaryGold = Color(0xFFF1C40F);
  
  /// Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);      // White
  static const Color textSecondary = Color(0xFFA0A8CF);    // Muted text
  static const Color textDisabled = Color(0xFF6B7280);
  
  /// Border & Divider
  static const Color border = Color(0xFF363C66);
  static const Color divider = Color(0xFF2D3159);

  // ==================== GRADIENTS ====================
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryAccent, secondaryAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [surfaceDark, primaryDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient gamingGradient = LinearGradient(
    colors: [Color(0xFF00D9FF), Color(0xFF7B2CBF), Color(0xFFFF006E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ==================== TYPOGRAPHY ====================
  
  /// Heading Font (Orbitron - Futuristic)
  static TextStyle get headingFont => GoogleFonts.orbitron();
  
  /// Body Font (Raleway - Clean, Readable)
  static TextStyle get bodyFont => GoogleFonts.raleway();
  
  /// Monospace for scores/stats
  static TextStyle get monoFont => GoogleFonts.jetBrainsMono();

  // ==================== TEXT STYLES ====================
  
  static TextStyle get h1 => headingFont.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: 1.2,
  );
  
  static TextStyle get h2 => headingFont.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: 0.8,
  );
  
  static TextStyle get h3 => headingFont.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );
  
  static TextStyle get bodyLarge => bodyFont.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textPrimary,
  );
  
  static TextStyle get bodyMedium => bodyFont.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );
  
  static TextStyle get bodySmall => bodyFont.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );
  
  static TextStyle get scoreDisplay => monoFont.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: primaryAccent,
    letterSpacing: 2,
  );

  // ==================== SPACING ====================
  
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double s = 12.0;
  static const double m = 16.0;
  static const double l = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // ==================== BORDER RADIUS ====================
  
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  // ==================== SHADOWS ====================
  
  static List<BoxShadow> get neonGlow => [
    BoxShadow(
      color: primaryAccent.withOpacity(0.4),
      blurRadius: 20,
      spreadRadius: 2,
    ),
  ];
  
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: primaryAccent.withOpacity(0.3),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  // ==================== THEME DATA ====================
  
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: primaryDark,
    primaryColor: primaryAccent,
    colorScheme: const ColorScheme.dark(
      primary: primaryAccent,
      secondary: secondaryAccent,
      tertiary: tertiaryAccent,
      surface: surfaceDark,
      background: primaryDark,
      error: hardRed,
      onPrimary: primaryDark,
      onSecondary: textPrimary,
      onSurface: textPrimary,
      onBackground: textPrimary,
    ),
    
    /// AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: primaryDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: h2.copyWith(fontSize: 20),
      iconTheme: const IconThemeData(color: textPrimary),
    ),
    
    /// Card Theme
    cardTheme: CardThemeData(
      color: surfaceDark,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        side: BorderSide(color: border, width: 1),
      ),
      shadowColor: Colors.black.withOpacity(0.3),
    ),
    
    /// Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryAccent,
        foregroundColor: primaryDark,
        elevation: 6,
        padding: const EdgeInsets.symmetric(horizontal: l, vertical: m),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        textStyle: bodyFont.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
        shadowColor: primaryAccent.withOpacity(0.5),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryAccent,
        textStyle: bodyFont.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    /// Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide(color: primaryAccent, width: 2),
      ),
      hintStyle: bodyMedium.copyWith(color: textDisabled),
      labelStyle: bodyMedium,
    ),
    
    /// Icon Theme
    iconTheme: const IconThemeData(
      color: primaryAccent,
      size: 24,
    ),
    
    /// Divider Theme
    dividerTheme: const DividerThemeData(
      color: divider,
      thickness: 1,
      space: m,
    ),
    
    /// Text Theme
    textTheme: TextTheme(
      displayLarge: h1,
      displayMedium: h2,
      displaySmall: h3,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
    ),
    
    /// Progress Indicator Theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryAccent,
      linearTrackColor: surfaceLight,
    ),
    
    /// Snackbar Theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: surfaceDark,
      contentTextStyle: bodyLarge,
      actionTextColor: primaryAccent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );

  // ==================== HELPER METHODS ====================
  
  /// Get difficulty color
  static Color getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return easyGreen;
      case 'medium':
      case 'normal':
        return mediumOrange;
      case 'hard':
        return hardRed;
      case 'expert':
        return expertPurple;
      default:
        return mediumOrange;
    }
  }
  
  /// Get rarity color
  static Color getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return commonGray;
      case 'rare':
        return rareBlue;
      case 'epic':
        return epicPurple;
      case 'legendary':
        return legendaryGold;
      default:
        return commonGray;
    }
  }
  
  /// Create neon border decoration
  static BoxDecoration neonBorder({Color? color, double width = 2}) {
    final borderColor = color ?? primaryAccent;
    return BoxDecoration(
      border: Border.all(color: borderColor, width: width),
      borderRadius: BorderRadius.circular(radiusMedium),
      boxShadow: [
        BoxShadow(
          color: borderColor.withOpacity(0.5),
          blurRadius: 12,
          spreadRadius: 1,
        ),
      ],
    );
  }
  
  /// Create gradient button decoration
  static BoxDecoration gradientButton({Gradient? gradient}) {
    return BoxDecoration(
      gradient: gradient ?? primaryGradient,
      borderRadius: BorderRadius.circular(radiusMedium),
      boxShadow: buttonShadow,
    );
  }
}
