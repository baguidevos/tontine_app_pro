import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Paya Brand Colors - Preserved exactly as requested
  static const Color payaBlue = Color(0xFF1A237E); // Deep Blue - Primary brand color
  static const Color payaLightBlue = Color(0xFF534BA6); // Soft Blue - Secondary
  static const Color payaCream = Color(0xFFFAF7F0); // Warm Cream - Background
  static const Color payaWhite = Color(0xFFFFFFFF); // Pure White
  static const Color payaGreen = Color(0xFF2E7D32); // Success Green
  static const Color payaOrange = Color(0xFFFF9800); // Action Orange
  static const Color payaRed = Color(0xFFE53935); // Error Red
  static const Color payaGray = Color(0xFF9E9E9E); // Neutral Gray
  static const Color payaSageGreen = Color(0xFF4CAF50); // Sage Green
  static const Color darkerBlue = Color(0xFF0D1457); // Darker version of payaBlue

  // Modern UI Accent & Surface Colors (harmonized with paya brand)
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);

  // Soft tint backgrounds for badges/chips
  static const Color greenLight = Color(0xFFE8F5E9);
  static const Color orangeLight = Color(0xFFFFF3E0);
  static const Color redLight = Color(0xFFFFEBEE);
  static const Color blueLight = Color(0xFFEDE7F6);

  // Legacy aliases (for backward compatibility)
  static const Color deepBlue = payaBlue;
  static const Color softBlue = payaLightBlue;
  static const Color warmCream = payaCream;
  static const Color successGreen = payaGreen;
  static const Color softRed = payaRed;
  static const Color sageGreen = payaSageGreen;

  // Modern Card Decorations
  static BoxDecoration modernCardDecoration({
    Color color = Colors.white,
    double borderRadius = 20,
    Color? borderColor,
    bool hasShadow = true,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? slate200.withValues(alpha: 0.8),
        width: 1,
      ),
      boxShadow: hasShadow
          ? [
              BoxShadow(
                color: payaBlue.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ]
          : null,
    );
  }

  // Modern Gradient Card Decoration
  static BoxDecoration gradientCardDecoration({
    required List<Color> colors,
    double borderRadius = 22,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(colors: colors, begin: begin, end: end),
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: colors.first.withValues(alpha: 0.28),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  static ThemeData get lightTheme {
    final baseTextTheme = ThemeData.light().textTheme;
    final modernTextTheme = GoogleFonts.plusJakartaSansTextTheme(baseTextTheme).copyWith(
      displayLarge: GoogleFonts.plusJakartaSans(
        color: darkerBlue,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
      ),
      displayMedium: GoogleFonts.plusJakartaSans(
        color: darkerBlue,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      displaySmall: GoogleFonts.plusJakartaSans(
        color: darkerBlue,
        fontWeight: FontWeight.w700,
      ),
      headlineLarge: GoogleFonts.plusJakartaSans(
        color: darkerBlue,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        color: darkerBlue,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      headlineSmall: GoogleFonts.plusJakartaSans(
        color: darkerBlue,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        color: darkerBlue,
        fontWeight: FontWeight.w700,
        fontSize: 18,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        color: darkerBlue,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        color: slate700,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        color: slate800,
        fontWeight: FontWeight.w400,
        fontSize: 15,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        color: slate700,
        fontWeight: FontWeight.w400,
        fontSize: 14,
        height: 1.4,
      ),
      bodySmall: GoogleFonts.plusJakartaSans(
        color: slate500,
        fontWeight: FontWeight.w400,
        fontSize: 12,
      ),
      labelLarge: GoogleFonts.plusJakartaSans(
        color: payaBlue,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      labelMedium: GoogleFonts.plusJakartaSans(
        color: slate600,
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        color: slate500,
        fontWeight: FontWeight.w500,
        fontSize: 11,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      scaffoldBackgroundColor: payaCream,
      colorScheme: ColorScheme.fromSeed(
        seedColor: payaBlue,
        primary: payaBlue,
        secondary: payaLightBlue,
        surface: payaWhite,
        surfaceContainerLow: slate50,
        surfaceContainer: Colors.white,
        error: payaRed,
        outline: slate200,
      ),
      textTheme: modernTextTheme,
      primaryTextTheme: modernTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: payaBlue,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        iconTheme: const IconThemeData(color: payaBlue, size: 22),
      ),
      cardTheme: CardThemeData(
        color: payaWhite,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: slate200.withValues(alpha: 0.8),
            width: 1,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: payaBlue,
          foregroundColor: payaWhite,
          elevation: 0,
          shadowColor: payaBlue.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: payaBlue,
          side: const BorderSide(color: slate300, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: payaBlue,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        labelStyle: GoogleFonts.plusJakartaSans(
          color: slate500,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          color: slate400,
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: slate200, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: slate200, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: payaBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: payaRed, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: payaRed, width: 2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: slate100,
        labelStyle: GoogleFonts.plusJakartaSans(
          color: slate700,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: slate200, width: 1),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: payaBlue,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: darkerBlue,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        modalBackgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }
}
