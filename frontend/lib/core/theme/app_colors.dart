import 'package:flutter/material.dart';

/// Colores centralizados de la aplicación Biblioteca Virtual Yavirac
class AppColors {
  // Colores principales de Yavirac
  static const Color yaviracBlue = Color(0xFF1E3A8A);
  static const Color yaviracBlueLight = Color(0xFF3B82F6);
  static const Color yaviracBlueDark = Color(0xFF1E40AF);
  static const Color yaviracOrange = Color(0xFFFF8C00);
  
  // Gradientes principales
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [yaviracBlue, yaviracBlueLight],
  );
  
  // Gradiente diagonal reutilizable
  static const LinearGradient diagonalGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [yaviracBlueDark, yaviracOrange],
  );
  
  // Alias para compatibilidad
  static const LinearGradient sidebarGradient = diagonalGradient;
  static const LinearGradient avatarGradient = diagonalGradient;
  
  static const LinearGradient roleGradient = LinearGradient(
    colors: [yaviracBlue, Colors.white],
  );
  
  static const LinearGradient menuItemGradient = LinearGradient(
    colors: [yaviracBlue, yaviracBlueLight],
  );
  
  static const LinearGradient logoutGradient = LinearGradient(
    colors: [yaviracBlue, Colors.white],
  );
  
  // Colores de estado
  static const Color success = Colors.green;
  static const Color error = Colors.red;
  static const Color warning = Colors.orange;
  static const Color info = yaviracBlueLight;
  
  // Colores de texto
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color textTertiary = Colors.white54;
  
  // Colores de fondo
  static const Color backgroundTransparent = Colors.transparent;
  
  // Métodos helper para opacidad
  static Color withOpacity(Color color, double opacity) => color.withOpacity(opacity);
  
  // Colores específicos para roles
  static Color getRoleTextColor(String role) {
    return role == 'admin' ? Colors.white : yaviracBlue;
  }
  
  // Sombras
  static BoxShadow get _defaultShadow => BoxShadow(
    color: yaviracBlueDark.withOpacity(0.3),
    blurRadius: 20,
    offset: const Offset(0, 10),
  );
  
  static BoxShadow get primaryShadow => _defaultShadow;
  static BoxShadow get avatarShadow => _defaultShadow;
  
  static BoxShadow get logoutShadow => BoxShadow(
    color: const Color(0xFFF093FB).withOpacity(0.3),
    blurRadius: 12,
    offset: const Offset(0, 6),
  );
}
