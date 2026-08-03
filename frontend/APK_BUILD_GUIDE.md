# 📱 Generación de APK - Biblioteca Virtual Yavirac

## 🚀 Generación Rápida

### Opción 1: Scripts Automatizados
```bash
# APK de producción (optimizada)
build_apk.bat

# APK de desarrollo (para pruebas)
build_debug_apk.bat
```

### Opción 2: Comandos Manuales

#### APK de Producción (Recomendado)
```bash
flutter clean
flutter pub get
flutter build apk --release --shrink --obfuscate --split-debug-info=build/debug-info --target-platform android-arm64
```

#### APK de Debug (Para pruebas)
```bash
flutter clean
flutter pub get
flutter build apk --debug
```

## 📋 Características de la APK

### ✨ Optimizaciones Implementadas
- **Minificación**: Código optimizado y comprimido
- **Ofuscación**: Protección del código fuente
- **Shrink Resources**: Eliminación de recursos no utilizados
- **ProGuard**: Optimización adicional de bytecode
- **Target ARM64**: Optimizado para dispositivos modernos

### 🎨 Diseño Móvil Elegante
- **Splash Screen**: Pantalla de carga animada con logo Yavirac
- **Tema Moderno**: Colores institucionales (Azul #1E3A8A, Naranja #FF8C00)
- **Material Design 3**: Interfaz moderna y consistente
- **Animaciones Fluidas**: Transiciones suaves entre pantallas
- **Optimización Móvil**: Widgets específicos para dispositivos móviles

### 🔧 Configuración Android
- **Nombre**: Biblioteca Virtual Yavirac
- **Package**: com.yavirac.biblioteca.digital
- **Versión**: 1.0.0
- **Min SDK**: 21 (Android 5.0+)
- **Target SDK**: 34 (Android 14)

## 📁 Ubicación de Archivos

### APK Generada
```
build/app/outputs/flutter-apk/
├── app-release.apk      # APK de producción
└── app-debug.apk        # APK de desarrollo
```

### Archivos de Debug (Solo Release)
```
build/debug-info/        # Información de debug para crash reports
```

## 🔍 Verificación de la APK

### Información de la APK
```bash
# Ver información detallada
flutter build apk --analyze-size

# Verificar tamaño
dir build\app\outputs\flutter-apk\*.apk
```

### Instalación en Dispositivo
```bash
# Instalar APK en dispositivo conectado
adb install build/app/outputs/flutter-apk/app-release.apk

# Desinstalar versión anterior
adb uninstall com.yavirac.biblioteca.digital
```

## 🎯 Características Específicas Móviles

### 🌟 Splash Screen Elegante
- Gradiente azul institucional
- Logo animado con efectos
- Indicador de carga moderno
- Transición suave a login

### 📱 Interfaz Optimizada
- **Status Bar**: Color azul institucional
- **Navigation Bar**: Integrada con tema
- **Cards**: Sombras elegantes y bordes redondeados
- **Botones**: Gradientes y efectos de presión
- **Campos de Texto**: Diseño Material con validación visual

### 🔒 Seguridad
- Ofuscación de código
- Protección contra ingeniería inversa
- Validación de certificados SSL
- Almacenamiento seguro de credenciales

## 🚨 Solución de Problemas

### Error de Compilación
```bash
# Limpiar completamente
flutter clean
flutter pub cache repair
flutter pub get
```

### Error de Gradle
```bash
# En android/
./gradlew clean
./gradlew build
```

### Error de Dependencias
```bash
# Actualizar dependencias
flutter pub upgrade
flutter pub deps
```

## 📊 Tamaño Optimizado

### Tamaños Aproximados
- **APK Release**: ~25-35 MB
- **APK Debug**: ~45-55 MB
- **Instalación**: ~60-80 MB

### Optimizaciones de Tamaño
- Eliminación de recursos no utilizados
- Compresión de imágenes
- Minificación de código
- Split por arquitectura (ARM64)

## 🔄 Proceso de Actualización

### Para Nueva Versión
1. Actualizar `version` en `pubspec.yaml`
2. Actualizar `versionCode` en `android/app/build.gradle`
3. Ejecutar `build_apk.bat`
4. Probar en dispositivos
5. Distribuir APK

## 📞 Soporte

Si encuentras problemas durante la generación:
1. Verifica que Flutter esté actualizado: `flutter doctor`
2. Revisa los logs de error en la consola
3. Consulta la documentación oficial de Flutter
4. Verifica que Android SDK esté correctamente configurado