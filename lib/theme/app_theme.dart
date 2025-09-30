import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryColor = Color(0xFF4CAF50); // Green
  static const Color accentColor = Color(0xFFFFCC02); // Yellow/Gold
  
  // Surface Colors
  static const Color backgroundColor = Color(0xFF121212); // Dark background
  static const Color surfaceColor = Color(0xFF1E1E1E); // Card surfaces
  static const Color cardColor = Color(0xFF2D2D2D); // Card background
  
  // Text Colors
  static const Color primaryTextColor = Colors.white;
  static const Color secondaryTextColor = Color(0xFFB0B0B0);
  
  // Energy Source Colors
  static const Color solarColor = Color(0xFFFF9800); // Orange
  static const Color windColor = Color(0xFF03A9F4); // Light Blue
  static const Color batteryColor = Color(0xFF4CAF50); // Green
  static const Color gridColor = Color(0xFFF44336); // Red
  static const Color loadColor = Color(0xFF9C27B0); // Purple
  
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