import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors
  static const Color mossGreen = Color(0xFF2D5A27);
  static const Color leafGreen = Color(0xFF4CAF50);
  static const Color mintGreen = Color(0xFF81C784);
  static const Color deepSoil = Color(0xFF212121);
  static const Color warmSand = Color(0xFFF5F0E8);
  static const Color mistWhite = Color(0xFFFAFAFA);
  static const Color sunGlow = Color(0xFFFFB74D);
  static const Color skyBlue = Color(0xFF64B5F6);
  static const Color roseGold = Color(0xFFE8B4B8);
  static const Color lavender = Color(0xFFB39DDB);
  static const Color coral = Color(0xFFFF8A65);
  static const Color slate = Color(0xFF37474F);
  static const Color charcoal = Color(0xFF1A1A1A);
  static const Color cream = Color(0xFFFFF8E1);

  // Gradients for existing widgets compatibility
  static const LinearGradient leafGradient = LinearGradient(
    colors: [leafGreen, mossGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunGradient = LinearGradient(
    colors: [Color(0xAAFFB74D), Color(0x00FFB74D)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static ThemeData get theme => ThemeData(
        fontFamily: 'SF Pro Display',
        scaffoldBackgroundColor: warmSand,
        colorScheme: ColorScheme.fromSeed(
          seedColor: mossGreen,
          brightness: Brightness.light,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: charcoal,
            letterSpacing: -1.0,
            height: 1.2,
          ),
          headlineSmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: charcoal,
            letterSpacing: -0.5,
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: charcoal,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: charcoal,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: charcoal,
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: slate,
            height: 1.4,
          ),
          labelSmall: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: slate,
            letterSpacing: 0.5,
          ),
        ),
      );

  // Compatibility alias for lightTheme
  static ThemeData get lightTheme => theme;
}
