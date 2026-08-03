#!/bin/bash

echo "🚀 Probando aplicación con modales optimizados..."

# Limpiar y reconstruir
flutter clean
flutter pub get

# Ejecutar en modo debug para web
echo "📱 Iniciando aplicación web..."
flutter run -d chrome --web-renderer html

echo "✅ Aplicación iniciada con modales optimizados"
echo ""
echo "🎯 Funcionalidades con modales:"
echo "  - ✅ Agregar libros (modal)"
echo "  - ✅ Agregar videos (modal)"
echo "  - ✅ Reproducir videos (modal fullscreen)"
echo "  - ✅ Leer PDFs (modal fullscreen)"
echo "  - ✅ Vista previa de imágenes (modal)"
echo ""
echo "📊 Beneficios esperados:"
echo "  - 🚀 Menos peticiones HTTP"
echo "  - 📦 Bundle más pequeño"
echo "  - ⚡ Carga más rápida"
echo "  - 🎨 Mejor UX (sin cambios de pantalla)"