@echo off
echo ========================================
echo    GENERANDO APK DE DEBUG
echo    Para pruebas y desarrollo
echo ========================================
echo.

echo [1/3] Limpiando proyecto...
flutter clean

echo [2/3] Obteniendo dependencias...
flutter pub get

echo [3/3] Generando APK de debug...
flutter build apk --debug

echo.
echo APK de debug generada exitosamente!
echo Ubicacion: build\app\outputs\flutter-apk\app-debug.apk
echo.
echo ========================================
echo    PROCESO COMPLETADO
echo ========================================

pause