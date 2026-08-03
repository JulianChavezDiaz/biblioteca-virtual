@echo off
echo ========================================
echo    GENERANDO APK OPTIMIZADA
echo    Biblioteca Virtual Yavirac
echo ========================================
echo.

echo [1/4] Limpiando proyecto...
flutter clean

echo [2/4] Obteniendo dependencias...
flutter pub get

echo [3/4] Generando APK de release optimizada...
flutter build apk --release --shrink --obfuscate --split-debug-info=build/debug-info --target-platform android-arm64

echo [4/4] APK generada exitosamente!
echo.
echo Ubicacion: build\app\outputs\flutter-apk\app-release.apk
echo.
echo ========================================
echo    PROCESO COMPLETADO
echo ========================================

pause