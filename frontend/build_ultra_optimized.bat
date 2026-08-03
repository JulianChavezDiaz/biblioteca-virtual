@echo off
echo 🚀 Iniciando build ultra-optimizado...

REM Limpiar completamente
flutter clean
flutter pub get

echo 📦 Construyendo con optimizaciones máximas...

REM Build con todas las optimizaciones
flutter build web ^
  --web-renderer html ^
  --release ^
  --tree-shake-icons ^
  --dart-define=FLUTTER_WEB_USE_SKIA=false ^
  --dart-define=FLUTTER_WEB_AUTO_DETECT=false ^
  --dart-define=FLUTTER_WEB_USE_EXPERIMENTAL_CANVAS_TEXT=false ^
  --no-source-maps ^
  --pwa-strategy=offline-first

echo ✅ Build completado!
echo 📊 Verificando tamaño del bundle...

dir build\web\*.js /s

echo 🎯 Optimizaciones aplicadas:
echo   - ✅ HTML renderer (más rápido)
echo   - ✅ Tree shaking de iconos
echo   - ✅ Sin Google Fonts (0 TTF)
echo   - ✅ Sin glassmorphism pesado
echo   - ✅ Caché de imágenes optimizado
echo   - ✅ Modales en lugar de pantallas
echo   - ✅ PWA offline-first

pause