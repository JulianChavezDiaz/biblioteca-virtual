import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class GlassTheme {
  // Usar colores centralizados
  static const Color primaryColor = AppColors.yaviracBlueDark;
  static const Color secondaryColor = AppColors.yaviracOrange;
  static const Color accentColor = Colors.white;
  static const Color successColor = Color(0xFF10B981);
  
  // Colores neon basados en Yavirac
  static const Color neonCyan = AppColors.yaviracOrange;
  static const Color neonPurple = AppColors.yaviracBlueDark;
  static const Color neonBlue = AppColors.yaviracBlue;
  static const Color neonPink = AppColors.yaviracOrange;
  
  static final BoxDecoration glassDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withOpacity(0.15),
        Colors.white.withOpacity(0.08),
      ],
    ),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: Colors.white.withOpacity(0.3),
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: primaryColor.withOpacity(0.1),
        blurRadius: 20,
        spreadRadius: 2,
      ),
    ],
  );

  static final decorationBackground = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.yaviracBlue,
        AppColors.yaviracBlueDark,
        AppColors.yaviracBlueDark.withOpacity(0.8),
        AppColors.yaviracBlue,
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    ),
  );

  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        background: const Color(0xFF1A1A2E), // Fallback
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.dark().textTheme,
      ),
      scaffoldBackgroundColor: AppColors.yaviracBlue,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
