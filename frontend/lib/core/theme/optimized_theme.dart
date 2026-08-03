import 'package:flutter/material.dart';

class OptimizedTheme {
  // Colores del tema
  static const Color primaryColor = Color(0xFF1E3A8A);
  static const Color secondaryColor = Color(0xFFEF4444);
  static const Color accentColor = Color(0xFFF59E0B);
  
  // Colores dedicados para tema claro
  static const Color lightScaffold = Color(0xFFF1F5F9);
  static const Color lightSurface = Colors.white;
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);

  // Gradientes optimizados (Dark Mode)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E3A8A),
      Color(0xFF3B82F6),
      Color(0xFF1E40AF),
    ],
  );

  // Gradientes optimizados (Light Mode)
  static const LinearGradient primaryGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF3B82F6),
      Color(0xFF60A5FA),
      Color(0xFF2563EB),
    ],
  );

  // Estilos de texto usando fuentes del sistema (Estáticos - Legacy/Dark default)
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontFamily: 'system-ui',
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    fontFamily: 'system-ui',
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    fontFamily: 'system-ui',
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Colors.white,
    fontFamily: 'system-ui',
  );

  static const TextStyle bodyTextSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colors.white70,
    fontFamily: 'system-ui',
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: Colors.white54,
    fontFamily: 'system-ui',
  );

  // --- Métodos Dinámicos para Texto ---
  
  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color getTextColor(BuildContext context) {
    return isDark(context) ? Colors.white : lightTextPrimary;
  }

  static TextStyle getHeading1(BuildContext context) => heading1.copyWith(color: getTextColor(context));
  static TextStyle getHeading2(BuildContext context) => heading2.copyWith(color: getTextColor(context));
  static TextStyle getHeading3(BuildContext context) => heading3.copyWith(color: getTextColor(context));
  static TextStyle getBodyText(BuildContext context) => bodyText.copyWith(color: getTextColor(context));
  
  // Decoraciones optimizadas
  static BoxDecoration glassmorphicDecoration = BoxDecoration(
    color: Colors.white.withOpacity(0.1),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.white.withOpacity(0.2)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 10,
        spreadRadius: 1,
      ),
    ],
  );

  static BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white.withOpacity(0.05),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.white.withOpacity(0.1)),
  );

  // Tema Oscuro (Original)
  static ThemeData get darkTheme => ThemeData(
    primarySwatch: Colors.blue,
    primaryColor: primaryColor,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0F172A),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: heading2,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontFamily: 'system-ui',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor),
      ),
      labelStyle: const TextStyle(color: Colors.white70, fontFamily: 'system-ui'),
      hintStyle: const TextStyle(color: Colors.white54, fontFamily: 'system-ui'),
    ),
  );

  // Tema Claro (Nuevo)
  static ThemeData get lightTheme => ThemeData(
    primarySwatch: Colors.blue,
    primaryColor: primaryColor,
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightScaffold,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: lightTextPrimary,
        fontFamily: 'system-ui',
      ),
      iconTheme: IconThemeData(color: lightTextPrimary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontFamily: 'system-ui',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor),
      ),
      labelStyle: const TextStyle(color: lightTextSecondary, fontFamily: 'system-ui'),
      hintStyle: const TextStyle(color: Colors.grey, fontFamily: 'system-ui'),
    ),
  );
  
  // Propiedad legacy para compatibilidad
  static ThemeData get theme => darkTheme;
}