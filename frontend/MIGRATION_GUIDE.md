# Guía de migración de Supabase a PostgreSQL local/producción

## Objetivo
Migrar los datos actuales de Supabase hacia una base PostgreSQL propia que use el backend que ya construimos, para dejar de depender de Supabase en producción.

## Qué se va a migrar
Idealmente se deben mover estas tablas si existen:
- users
- books
- videos
- favorites
- reading_history
- requests
- book_stats
- book_opens_history

## Antes de empezar
Asegúrate de tener:
- acceso a la base Supabase actual,
- PostgreSQL instalado localmente o en el servidor de producción,
- el backend funcionando con la nueva base,
- un respaldo de la base actual.

## Recomendación general
No intentes migrar todo de golpe si la base es grande. Hazlo por partes:
1. usuarios,
2. libros,
3. contenido asociado,
4. favoritos/historial,
5. solicitudes.

## Paso 1: crear la nueva base de datos
Si vas a trabajar localmente:
```bash
psql -U postgres -h localhost -p 5434 -d postgres
```

Dentro de psql:
```sql
CREATE DATABASE biblioteca;
```

Luego crea las tablas usando los scripts del proyecto:
```bash
psql -U postgres -h localhost -p 5434 -d biblioteca -f migration/setup_local_postgres.sql
```

## Paso 2: revisar el esquema actual de Supabase
En Supabase, revisa las tablas y columnas reales. Puede haber diferencias con el esquema que tenemos en local, por ejemplo:
- columnas con nombres distintos,
- tipos de datos diferentes,
- valores nulos,
- UUIDs o IDs de tipo text.

## Paso 3: exportar datos desde Supabase
Si tienes acceso por psql o pgAdmin, puedes exportar datos tabla por tabla.

Ejemplo para exportar una tabla:
```bash
pg_dump --host=tu-host-supabase --username=tu-usuario --dbname=tu-db --table=public.users --data-only > users_data.sql
```

O si usas el SQL Editor de Supabase, puedes correr consultas como:
```sql
SELECT * FROM public.users;
```

## Paso 4: preparar los datos para la nueva base
Antes de importar, revisa:
- si `users` tiene `password_hash` o no,
- si los IDs son UUIDs válidos,
- si hay tablas con claves foráneas que dependan de `users` u otros registros,
- si hay columnas que no existen en el nuevo esquema.

### Consejo importante
Si vas a usar autenticación local con tu backend, los usuarios de Supabase pueden no tener `password_hash`. En ese caso:
- o los dejas sin contraseña y no los puedes autenticar localmente,
- o les asignas una contraseña temporal más adelante.

## Paso 5: importar los datos a la nueva base
Ejemplo:
```bash
psql -U postgres -h localhost -p 5434 -d biblioteca -f users_data.sql
```

Hazlo tabla por tabla:
```bash
psql -U postgres -h localhost -p 5434 -d biblioteca -f books_data.sql
psql -U postgres -h localhost -p 5434 -d biblioteca -f videos_data.sql
```

## Paso 6: verificar integridad de los datos
Después de importar, revisa:
```sql
SELECT COUNT(*) FROM public.users;
SELECT COUNT(*) FROM public.books;
SELECT COUNT(*) FROM public.videos;
```

Y valida que no haya errores de claves foráneas:
```sql
SELECT * FROM public.books WHERE created_by IS NOT NULL AND created_by NOT IN (SELECT id FROM public.users);
```

## Paso 7: probar el backend contra la nueva base
Asegúrate de que el backend apunte a la nueva base en el archivo .env:
```env
DB_HOST=localhost
DB_PORT=5434
DB_NAME=biblioteca
DB_USER=postgres
DB_PASSWORD=12345
```

Luego inicia el backend:
```bash
cd server
node server.js
```

Prueba:
- login,
- registro,
- consulta de libros,
- crear un libro nuevo.

## Paso 8: cambiar la app a producción
Una vez que la migración funcione:
1. despliega el backend en un servidor o servicio de producción,
2. cambia las variables de entorno para usar la base de producción,
3. apunta el frontend al nuevo backend,
4. deja de consumir Supabase para estas operaciones.

## Recomendaciones importantes
### 1. Haz una copia de seguridad primero
Antes de importar datos, respalda todo.

### 2. Migra por tablas
No intentes importar todo de una sola vez si no estás seguro del esquema.

### 3. Revisa UUIDs y claves foráneas
Esto suele ser el punto más delicado.

### 4. Mantén los scripts SQL
Guarda los scripts de creación y de importación en carpetas como:
- migration/
- scripts/

### 5. Prueba el flujo completo
Verifica:
- registro,
- login,
- libros,
- favoritos,
- historial,
- soporte.

## Comandos útiles para copiar y pegar
### Crear base local
```bash
psql -U postgres -h localhost -p 5434 -d postgres -c "CREATE DATABASE biblioteca;"
```

### Crear tablas
```bash
psql -U postgres -h localhost -p 5434 -d biblioteca -f migration/setup_local_postgres.sql
```

### Verificar tablas
```bash
psql -U postgres -h localhost -p 5434 -d biblioteca -c "\dt"
```

### Contar registros
```bash
psql -U postgres -h localhost -p 5434 -d biblioteca -c "SELECT COUNT(*) FROM public.users;"
```

### Iniciar backend
```bash
cd server
node server.js
```

## Plan recomendado para hacerlo con calma
1. Crear la nueva base PostgreSQL.
2. Crear el esquema con los scripts del proyecto.
3. Exportar usuarios y libros primero.
4. Importarlos y probar.
5. Después migrar favoritos, historial y solicitudes.
6. Probar login y lectura desde el backend.
7. Finalmente cambiar producción.

## Consejos finales
- Si la migración se complica, hazla en lotes pequeños.
- Mantén un registro de qué tablas ya fueron migradas.
- Si tienes muchos datos, mejor hacer una migración controlada con scripts SQL y pruebas entre cada paso.
- Evita depender de Supabase para autenticación y contenido en producción cuando ya tengas el backend propio.

## Resumen corto
La idea es simple:
- exportar datos desde Supabase,
- importar a PostgreSQL propio,
- ajustar el backend para usar esa base,
- y dejar Supabase solo como respaldo o como referencia temporal.
