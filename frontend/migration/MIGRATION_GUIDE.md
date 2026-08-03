# Guía de Migración de Supabase a PostgreSQL Local/Remoto

## Paso 1: Obtener credenciales de Supabase
1. Ve a tu proyecto Supabase
2. Settings > Database
3. Copia la Connection String

## Paso 2: Exportar desde Supabase
```bash
# Exportar solo schema (estructura)
pg_dump "postgresql://postgres:[PASSWORD]@db.[PROJECT-REF].supabase.co:5432/postgres" \
  --schema-only \
  --no-owner \
  --no-privileges \
  -f schema_export.sql

# Exportar solo datos
pg_dump "postgresql://postgres:[PASSWORD]@db.[PROJECT-REF].supabase.co:5432/postgres" \
  --data-only \
  --no-owner \
  --no-privileges \
  -f data_export.sql

# Exportar todo (schema + datos)
pg_dump "postgresql://postgres:[PASSWORD]@db.[PROJECT-REF].supabase.co:5432/postgres" \
  --no-owner \
  --no-privileges \
  -f full_export.sql
```

## Paso 3: Importar a nueva base
```bash
# Crear nueva base de datos
createdb biblioteca_digital

# Importar schema
psql -d biblioteca_digital -f schema_export.sql

# Importar datos
psql -d biblioteca_digital -f data_export.sql
```

## Paso 4: Modificar conexión en Flutter
Cambiar en `lib/core/constants/supabase_config.dart`:
```dart
// Antes (Supabase)
static const String supabaseUrl = 'https://xxx.supabase.co';
static const String supabaseAnonKey = 'xxx';

// Después (PostgreSQL directo)
static const String postgresHost = 'tu-servidor.com';
static const String postgresPort = '5432';
static const String postgresDatabase = 'biblioteca_digital';
static const String postgresUser = 'tu_usuario';
static const String postgresPassword = 'tu_password';
```

## Consideraciones importantes:
- Supabase usa auth.users para autenticación
- Tendrás que manejar autenticación manualmente
- Las políticas RLS no se migran automáticamente
- Storage de archivos hay que migrarlo por separado