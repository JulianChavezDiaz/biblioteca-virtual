/// Constantes globales de la aplicación
class AppConstants {
  // Información de la aplicación
  static const String appName = 'Biblioteca Digital';
  static const String appVersion = '1.0.0';
  static const String baseUrl = 'https://api.bibliotecadigital.com';
  
  // Rutas de navegación
  static const String homeRoute = '/';
  static const String loginRoute = '/login';
  static const String libraryRoute = '/library';
  static const String readerRoute = '/reader';
  static const String adminRoute = '/admin';
  
  // Configuración de paginación
  static const int booksPerPage = 20;
  static const int videosPerPage = 10;
  static const int maxCacheSize = 100;
  
  // Configuración de caché
  static const Duration cacheExpiry = Duration(minutes: 5);
  
  // Límites de validación
  static const int minPasswordLength = 6;
  static const int maxTitleLength = 255;
  static const int maxDescriptionLength = 1000;
}