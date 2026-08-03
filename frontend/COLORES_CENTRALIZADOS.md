# Sistema de Colores Centralizado - Biblioteca Virtual Yavirac

## 📋 Resumen
Se ha implementado un sistema de colores centralizado para reemplazar los valores hardcodeados en toda la aplicación. Esto mejora la mantenibilidad y consistencia visual.

## 🎨 Archivo Principal: `app_colors.dart`

### Colores Principales
```dart
static const Color yaviracBlue = Color(0xFF1E3A8A);      // Azul principal Yavirac
static const Color yaviracBlueLight = Color(0xFF3B82F6); // Azul claro Yavirac  
static const Color yaviracBlueDark = Color(0xFF1E40AF);  // Azul oscuro Yavirac
static const Color yaviracOrange = Color(0xFFFF8C00);    // Naranja Yavirac
```

### Gradientes Predefinidos
```dart
static const LinearGradient primaryGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [yaviracBlue, yaviracBlueLight],
);

static const LinearGradient sidebarGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [yaviracBlueDark, yaviracOrange],
);
```

### Sombras Predefinidas
```dart
static BoxShadow get primaryShadow => BoxShadow(
  color: yaviracBlueDark.withOpacity(0.3),
  blurRadius: 20,
  offset: const Offset(0, 10),
);
```

## 🔄 Archivos Actualizados

### ✅ Completamente Actualizados
- `user_home.dart` - Pantalla principal del usuario
- `glass_theme.dart` - Tema principal de la aplicación  
- `login_screen.dart` - Pantalla de inicio de sesión

### ⚠️ Pendientes de Actualización
Los siguientes archivos aún contienen colores hardcodeados:

- `admin_dashboard.dart` (15 colores)
- `app_theme.dart` (11 colores)
- `user_home.dart` (12 colores restantes)
- `librarian_dashboard.dart` (8 colores)
- `flipbook_reader.dart` (4 colores)
- `users_management_screen.dart` (3 colores)
- `teacher_dashboard.dart` (2 colores)
- `glass_theme.dart` (2 colores restantes)
- `simple_book_reader.dart` (1 color)
- `support_screen.dart` (1 color)
- `futuristic_widgets.dart` (1 color)

## 📝 Cómo Usar el Sistema

### 1. Importar el archivo
```dart
import '../../../core/theme/app_colors.dart';
```

### 2. Reemplazar colores hardcodeados

**❌ Antes:**
```dart
Color(0xFF1E3A8A)
```

**✅ Después:**
```dart
AppColors.yaviracBlue
```

### 3. Usar gradientes predefinidos

**❌ Antes:**
```dart
LinearGradient(
  colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
)
```

**✅ Después:**
```dart
AppColors.primaryGradient
```

### 4. Usar sombras predefinidas

**❌ Antes:**
```dart
BoxShadow(
  color: Color(0xFF1E40AF).withOpacity(0.3),
  blurRadius: 20,
  offset: Offset(0, 10),
)
```

**✅ Después:**
```dart
AppColors.primaryShadow
```

## 🎯 Beneficios

1. **Consistencia**: Todos los colores siguen la paleta oficial de Yavirac
2. **Mantenibilidad**: Cambios centralizados se reflejan en toda la app
3. **Legibilidad**: Nombres descriptivos en lugar de códigos hexadecimales
4. **Escalabilidad**: Fácil agregar nuevos colores y variaciones

## 🚀 Próximos Pasos

1. Actualizar los archivos pendientes uno por uno
2. Agregar más variaciones de colores según sea necesario
3. Implementar modo oscuro/claro usando el mismo sistema
4. Crear tests para validar la consistencia de colores

## 🔍 Comando para Buscar Colores Hardcodeados

```powershell
Get-ChildItem -Path lib -Recurse -Include *.dart | ForEach-Object { 
  $content = Get-Content $_.FullName -Raw; 
  $matches = [regex]::Matches($content, 'Color\(0x[A-Fa-f0-9]{8}\)'); 
  if ($matches.Count -gt 0) { 
    Write-Host "$($_.Name): $($matches.Count) colores hardcodeados" 
  } 
}
```