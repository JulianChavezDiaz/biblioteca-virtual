# 🔄 MIGRACIÓN USANDO SQL EDITOR DE SUPABASE

## Paso 1: En tu CUENTA ACTUAL
1. Ve a **SQL Editor**
2. Ejecuta las queries del archivo `export_queries.sql` **UNA POR UNA**
3. **Copia los resultados** de cada query (serán INSERT statements)

## Paso 2: En tu CUENTA NUEVA  
1. Ve a **SQL Editor**
2. **Pega y ejecuta** todos los INSERT statements que copiaste

## Paso 3: Cambiar configuración en Flutter
En `lib/core/constants/supabase_config.dart`:

```dart
// CAMBIAR ESTAS LÍNEAS:
static const String supabaseUrl = 'https://pnefkrshzhlelycbxhqg.supabase.co';
static const String supabaseAnonKey = 'TU-NUEVA-ANON-KEY';
```

## 🔑 Para obtener tu nueva Anon Key:
1. En tu cuenta NUEVA → **Settings** → **API**
2. Copia el **anon public** key

## ✅ Orden de ejecución:
1. **Primero**: usuarios (porque otras tablas dependen de ellos)
2. **Segundo**: libros y videos
3. **Tercero**: favoritos e historial

## 🚨 Si hay errores:
- **Comillas simples**: Ya están escapadas en las queries
- **Valores NULL**: Están manejados
- **Dependencias**: Respeta el orden de ejecución

¿Listo para empezar?