import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF7289DA);
  static const Color darkBg = Color(0xFF23272A);
  static const Color darkerBg = Color(0xFF2C2F33);
  static const Color lightText = Color(0xFFFFFFFF);
  static const Color mutedText = Color(0xFF99AAB5);
  static const Color accentColor = Color(0xFF43B581);
  static const Color errorColor = Color(0xFFF04747);
  
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: darkBg,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        surface: darkerBg,
        error: errorColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkerBg,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        color: darkerBg,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: lightText,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkerBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: lightText),
        bodyMedium: TextStyle(color: lightText),
        bodySmall: TextStyle(color: mutedText),
      ),
    );
  }
}
