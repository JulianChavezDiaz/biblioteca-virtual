import 'package:flutter/material.dart';

/// Gestor centralizado del tema de la aplicación
class ThemeManager {
  static final ValueNotifier<bool> isDarkMode = ValueNotifier<bool>(false);
  
  /// Alterna entre tema claro y oscuro
  static void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
  }
  
  /// Obtiene el tema actual
  static bool get currentTheme => isDarkMode.value;
  
  /// Establece el tema directamente
  static void setTheme(bool isDark) {
    isDarkMode.value = isDark;
  }
}
