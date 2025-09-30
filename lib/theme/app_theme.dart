import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors - Simplified and Kid-Friendly
  static const Color primaryColor = Color(0xFF2E7D32); // Forest Green
  static const Color accentColor = Color(0xFF1976D2); // Bright Blue
  
  // Surface Colors - Softer and More Approachable
  static const Color backgroundColor = Color(0xFF1A1A1A); // Softer dark
  static const Color surfaceColor = Color(0xFF2C2C2C); // Lighter card surfaces
  static const Color cardColor = Color(0xFF3A3A3A); // More visible cards
  
  // Text Colors - Better Contrast
  static const Color primaryTextColor = Color(0xFFFFFFFF);
  static const Color secondaryTextColor = Color(0xFFE0E0E0);
  
  // Energy Source Colors - Simplified and Consistent
  static const Color solarColor = Color(0xFFFFA726); // Friendly Orange
  static const Color windColor = Color(0xFF42A5F5); // Sky Blue
  static const Color batteryColor = Color(0xFF66BB6A); // Fresh Green
  static const Color gridColor = Color(0xFFEF5350); // Soft Red
  static const Color loadColor = Color(0xFFAB47BC); // Gentle Purple
  
  // Status Colors
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFF44336);
  
  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF4CAF50),
    Color(0xFF81C784),
  ];
  
  static const List<Color> accentGradient = [
    Color(0xFFFFCC02),
    Color(0xFFFFD54F),
  ];
  
  // Chart Colors
  static const List<Color> chartColors = [
    Color(0xFFFF9800), // Solar - Orange
    Color(0xFF03A9F4), // Wind - Light Blue
    Color(0xFF9C27B0), // Load - Purple
    Color(0xFF4CAF50), // Battery - Green
    Color(0xFFF44336), // Grid - Red
  ];
  
  // Helper method to get theme data
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        surface: surfaceColor,
        onSurface: primaryTextColor,
        error: errorColor,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: cardColor,
        foregroundColor: primaryTextColor,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: const CardThemeData(
        color: cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      scaffoldBackgroundColor: backgroundColor,
    );
  }
}