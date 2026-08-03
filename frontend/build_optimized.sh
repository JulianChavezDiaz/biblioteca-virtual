#!/bin/bash

# Script para build optimizado de Flutter Web

echo "🚀 Iniciando build optimizado para web..."

# Limpiar build anterior
flutter clean
flutter pub get

# Build con optimizaciones máximas
flutter build web \
  --web-renderer html \
  --dart-define=FLUTTER_WEB_USE_SKIA=false \
  --dart-define=FLUTTER_WEB_AUTO_DETECT=false \
  --release \
  --tree-shake-icons \
  --source-maps \
  --split-debug-info=build/web/debug_symbols

echo "✅ Build completado en build/web/"
echo "📊 Estadísticas del bundle:"

# Mostrar tamaño de archivos principales
ls -lh build/web/main.dart.js
ls -lh build/web/flutter.js

echo "🎯 Para reducir más el tamaño:"
echo "1. Eliminar dependencias no usadas"
echo "2. Usar widgets nativos en lugar de packages"
echo "3. Optimizar imágenes"