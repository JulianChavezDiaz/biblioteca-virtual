# 📋 GUÍA PASO A PASO - MIGRACIÓN DE SUPABASE

## OPCIÓN A: Migración automática (Recomendada)

### Paso 1: Obtener datos de Supabase
1. Ve a tu proyecto Supabase
2. **Settings** → **Database** 
3. Copia la **Connection string**
4. Se ve así: `postgresql://postgres:[PASSWORD]@db.[PROJECT-REF].supabase.co:5432/postgres`

### Paso 2: Exportar datos
```bash
# Reemplaza TU_CONNECTION_STRING con la URL de arriba
pg_dump "TU_CONNECTION_STRING" \
  --schema=public \
  --no-owner \
  --no-privileges \
  --clean \
  -f mi_biblioteca.sql
```

### Paso 3: Importar en nueva base
```bash
# Conectar a tu nueva base PostgreSQL
psql -h TU_NUEVO_SERVIDOR -U TU_USUARIO -d TU_NUEVA_BASE -f mi_biblioteca.sql
```

---

## OPCIÓN B: Migración manual (Si no tienes pg_dump)

### Paso 1: Crear estructura
1. Ejecuta el archivo `schema_limpio.sql` en tu nueva base
2. Esto creará todas las tablas vacías

### Paso 2: Exportar datos desde Supabase
1. Ve a **Table Editor** en Supabase
2. Para cada tabla (users, books, videos, etc.):
   - Selecciona todos los registros
   - **Export** → **CSV**
   - Guarda como `tabla_users.csv`, `tabla_books.csv`, etc.

### Paso 3: Importar datos
```sql
-- En tu nueva base PostgreSQL
COPY users FROM '/ruta/tabla_users.csv' DELIMITER ',' CSV HEADER;
COPY books FROM '/ruta/tabla_books.csv' DELIMITER ',' CSV HEADER;
COPY videos FROM '/ruta/tabla_videos.csv' DELIMITER ',' CSV HEADER;
-- Repetir para todas las tablas
```

---

## Paso 4: Actualizar Flutter

### Cambiar configuración de Supabase
En `lib/core/constants/supabase_config.dart`:
```dart
// ANTES
static const String supabaseUrl = 'https://xxx.supabase.co';
static const String supabaseAnonKey = 'xxx';

// DESPUÉS  
static const String supabaseUrl = 'https://TU-NUEVO-SERVIDOR.com';
static const String supabaseAnonKey = 'TU-NUEVA-KEY';
```

---

## ✅ Verificación final

1. **Probar conexión**: Tu app debería conectar sin errores
2. **Verificar datos**: Los usuarios, libros y videos deben aparecer
3. **Probar funciones**: Login, registro, subir archivos

---

## 🆘 Si algo falla

1. **Error de conexión**: Verifica URL y credenciales
2. **Tablas vacías**: Revisa que los datos se importaron
3. **Errores de permisos**: Asegúrate que el usuario tenga permisos

¿Con cuál opción quieres empezar?