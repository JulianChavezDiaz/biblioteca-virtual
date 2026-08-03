# 🔄 MIGRACIÓN ENTRE CUENTAS SUPABASE

## Paso 1: Obtener connection strings

### Cuenta ACTUAL (origen):
```
postgresql://postgres:[PASSWORD-ACTUAL]@db.[PROJECT-ACTUAL].supabase.co:5432/postgres
```

### Cuenta NUEVA (destino):
```
postgresql://postgres:[PASSWORD-NUEVA]@db.pnefkrshzhlelycbxhqg.supabase.co:5432/postgres
```

## Paso 2: Exportar desde cuenta actual
```bash
pg_dump "postgresql://postgres:[PASSWORD-ACTUAL]@db.[PROJECT-ACTUAL].supabase.co:5432/postgres" \
  --schema=public \
  --no-owner \
  --no-privileges \
  --clean \
  -f biblioteca_backup.sql
```

## Paso 3: Importar a cuenta nueva
```bash
psql "postgresql://postgres:[PASSWORD-NUEVA]@db.pnefkrshzhlelycbxhqg.supabase.co:5432/postgres" \
  -f biblioteca_backup.sql
```

## Paso 4: Cambiar en Flutter
En `lib/core/constants/supabase_config.dart`:
```dart
// CAMBIAR ESTAS LÍNEAS:
static const String supabaseUrl = 'https://pnefkrshzhlelycbxhqg.supabase.co';
static const String supabaseAnonKey = 'TU-NUEVA-ANON-KEY';
```

## ✅ Ventajas de esta migración:
- ✅ Mantienes todas las funciones de Supabase (Auth, Storage, etc.)
- ✅ Solo cambias 2 líneas en Flutter
- ✅ Tu cuenta actual sigue funcionando hasta que confirmes
- ✅ Cero cambios en el código de la app

## 🔑 Necesitas obtener:
1. Connection string de tu cuenta ACTUAL
2. Anon Key de tu cuenta NUEVA (Settings → API)