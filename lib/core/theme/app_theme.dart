import 'package:flutter/material.dart';

class AppTheme {
  // Paya Brand Colors
  static const Color payaBlue = Color(
    0xFF1a237e,
  ); // Deep Blue - Primary brand color
  static const Color payaLightBlue = Color(0xFF534ba6); // Soft Blue - Secondary
  static const Color payaCream = Color(0xFFFfaf7f0); // Warm Cream - Background
  static const Color payaWhite = Color(0xFFFFFFFF); // Pure White
  static const Color payaGreen = Color(0xFF2e7d32); // Success Green
  static const payaOrange = Color(0xFFFF9800); // Action Orange
  static const Color payaRed = Color(0xFFe53935); // Error Red
  static const Color payaGray = Color(0xFF9e9e9e); // Neutral Gray

  // Legacy aliases (for backward compatibility)
  static const Color deepBlue = payaBlue;
  static const Color softBlue = payaLightBlue;
  static const Color warmCream = payaCream;
  static const Color successGreen = payaGreen;
  static const Color softRed = payaRed;
  static const Color darkerBlue = Color(
    0xFF0d1457,
  ); // Darker version of payaBlue

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: payaCream,
      colorScheme: ColorScheme.fromSeed(
        seedColor: payaBlue,
        primary: payaBlue,
        secondary: payaLightBlue,
        surface: payaWhite,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: payaWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: payaBlue,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: payaBlue),
      ),
      cardTheme: CardThemeData(
        color: payaWhite,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: payaBlue,
          foregroundColor: payaWhite,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: deepBlue, width: 2),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: darkerBlue,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: darkerBlue,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(color: darkerBlue, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: darkerBlue),
        bodyMedium: TextStyle(color: darkerBlue),
      ),
    );
  }
}
