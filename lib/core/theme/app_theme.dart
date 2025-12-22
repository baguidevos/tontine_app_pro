import 'package:flutter/material.dart';

class AppTheme {
  static const Color sageGreen = Color(0xFFB2AC88);
  static const Color softBlue = Color(0xFFA8DADC);
  static const Color warmCream = Color(0xFFF1FAEE);
  static const Color deepBlue = Color(0xFF457B9D);
  static const Color darkerBlue = Color(0xFF1D3557);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: warmCream,
      colorScheme: ColorScheme.fromSeed(
        seedColor: deepBlue,
        primary: deepBlue,
        secondary: softBlue,
        surface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: darkerBlue,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: darkerBlue),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: deepBlue,
          foregroundColor: Colors.white,
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
