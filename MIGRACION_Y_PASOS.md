# Biblioteca Digital — Migración de Supabase a backend propio

Guía de lo que se hizo y **lo que falta por hacer** para dejar el proyecto corriendo.

- **Front (Flutter web):** `backend-titulacion/biblioteca-frontend-desarrollo`
- **Back (Next.js + Postgres):** `biblioteca-backend`

La app dejó de usar Supabase. Ahora el front habla por **HTTP** con un backend
Next.js + PostgreSQL, con autenticación propia por **JWT**.

---

## ✅ Lo que ya está hecho

- Backend Next.js + Prisma + Postgres completo (auth, libros, videos, categorías,
  favoritos, solicitudes de soporte, estadísticas, usuarios, subida de archivos).
- Front migrado 100%: **cero** referencias a `supabase_flutter` / `Supabase.instance`.
- `supabase_flutter` eliminado del `pubspec.yaml`.
- Esquema del backend reconciliado con el esquema real de Supabase.
- Datos reales exportados listos para importar (`biblioteca-backend/prisma/seed-data/`):
  - `01_data.sql` → 807 libros, 463 usuarios, 28 videos, 92 favoritos, 493 stats
  - `02_passwords.sql` → 463 contraseñas (hash bcrypt, se conservan los logins)

---

## ▶️ Pasos para poner en marcha

### 1. Backend + base de datos

```bash
cd "D:\Proyectos\Biblioteca\biblioteca-backend"

# a) Levantar PostgreSQL (Docker). Alternativa: usar Postgres local y editar .env
docker compose up -d

# b) Dependencias (si no se instalaron)
npm install

# c) Crear las tablas a partir del esquema Prisma
npm run db:push

# d) (Opcional pero recomendado) Importar tus datos reales de Supabase
#    Ajusta la cadena de conexión si cambiaste credenciales:
psql "postgresql://biblioteca:biblioteca@localhost:5432/biblioteca" -f prisma/seed-data/01_data.sql
psql "postgresql://biblioteca:biblioteca@localhost:5432/biblioteca" -f prisma/seed-data/02_passwords.sql

#    Si NO importas datos, crea usuarios de prueba:
#    npm run db:seed

# e) Arrancar el backend (queda en http://localhost:4000)
npm run dev
```

Verificación: abre <http://localhost:4000/api/health> → debe responder
`{ "status": "ok", "db": "up" }`.

> **Nota sobre `psql`:** viene con PostgreSQL. Si no está en el PATH, úsalo con ruta
> completa, p. ej. `& "C:\Program Files\PostgreSQL\17\bin\psql.exe" ...`

### 2. Frontend (Flutter)

```bash
cd "D:\Proyectos\Biblioteca\backend-titulacion\biblioteca-frontend-desarrollo"

# a) Reinstalar dependencias (se quitó supabase_flutter)
flutter pub get

# b) Validar que compila
flutter analyze

# c) Ejecutar (la URL por defecto ya apunta a http://localhost:4000/api)
flutter run -d chrome
```

Para apuntar a otra URL (backend desplegado, IP de red, etc.):

```bash
flutter run -d chrome --dart-define=API_BASE_URL=https://tu-backend.com/api
```

---

## ⏳ Lo que falta / pendientes

### 🔴 Obligatorio antes de dar por cerrado
- [ ] `flutter pub get` + `flutter analyze` sin errores (no se pudo correr en el entorno de migración).
- [ ] Importar los datos (`seed-data/*.sql`) o poblar la BD.
- [ ] Probar los flujos clave: login, ver libros/videos, favoritos, panel admin.

### 🟠 Archivos (portadas y PDFs) — IMPORTANTE
El backup de Supabase **no incluye los archivos** (estaban en Supabase Storage, que
es un servicio aparte). Por eso las columnas `cover_url` / `file_url` de los libros
importados apuntan a URLs viejas de Supabase que **ya no funcionan**.

Opciones:
- [ ] Re-subir los archivos con el nuevo endpoint `POST /api/uploads` (la app ya lo usa
      al crear/editar libros), o
- [ ] Migrar el bucket de Supabase Storage aparte y actualizar las URLs.

### 🟡 Funcionalidad degradada (no bloquea, mejorar luego)
- [ ] **Reset de contraseña por email:** quedó como aviso ("no disponible"). Falta un
      endpoint `POST /api/auth/reset-password/confirm` + proveedor de email (Resend/SMTP).
- [ ] **Solicitudes de soporte en tiempo real:** antes usaba realtime de Supabase; ahora
      es una carga puntual (se refresca al reabrir). Si se quiere "en vivo", añadir polling
      o WebSockets en el backend.

### 🔵 Limpieza opcional
- [ ] Eliminar carpetas de plataformas no-web (`android/`, `ios/`, `macos/`, `linux/`,
      `windows/`) si el objetivo es **solo web**.
- [ ] Renombrar la clase `SupabaseAuthService` (ya no usa Supabase) a algo como `AuthService`.
- [ ] Quitar el `package-lock.json` suelto del repo del front (artefacto npm, no aplica a Flutter).

---

## 🚀 Despliegue (referencia rápida)

- **Backend:** cualquier host con Node 20+ y acceso a un Postgres (Railway, Render, VPS,
  Fly.io, etc.). Define las variables `DATABASE_URL`, `JWT_SECRET` y `CORS_ORIGIN`.
  Los archivos subidos se guardan en `public/uploads` (si el host es efímero, usar un
  volumen persistente o un bucket).
- **Front:** `flutter build web --dart-define=API_BASE_URL=https://tu-backend/api` y
  servir la carpeta `build/web` (Netlify, Vercel estático, etc.).

---

## 🔑 Usuarios (tras importar datos)

Los usuarios reales conservan su email y contraseña (hash bcrypt migrado). El
administrador principal en los datos es `git@yavirac.edu.ec` (rol `admin`).

Si usas `npm run db:seed` en vez de importar, se crean usuarios de prueba
(`admin@yavirac.edu.ec` / `admin123`, etc. — **cámbialos** antes de producción).

---

## 📋 Referencia de endpoints (backend)

| Método | Ruta | Descripción |
| ------ | ---- | ----------- |
| POST | `/api/auth/register` · `/api/auth/login` | registro / login → `{ token, user }` |
| GET · PATCH | `/api/auth/me` | usuario del token · actualizar nombre/contraseña propios |
| GET · POST | `/api/books` | listar (`?search=&category=&physical=1`) · crear |
| GET · PUT · DELETE | `/api/books/:id` | detalle · editar · borrar (soft-delete) |
| POST | `/api/books/:id/open` | registrar apertura (+contador) |
| GET · POST | `/api/videos` · `/api/videos/:id` | CRUD de videos |
| GET · POST · PUT · DELETE | `/api/categories` · `/api/categories/:id` | CRUD categorías |
| GET · POST · DELETE | `/api/favorites` (`?full=1`) · `/api/favorites/:bookId` | favoritos |
| GET · POST · PATCH · DELETE | `/api/support-requests` · `/api/support-requests/:id` | solicitudes |
| GET | `/api/stats/top-books` (`?limit=`) · `/api/stats/recent` | estadísticas |
| POST | `/api/reading-progress` | progreso de lectura |
| GET | `/api/users` · `/api/users/:id` | usuarios (staff/admin) |
| PATCH · DELETE | `/api/users/:id` | editar (nombre/rol/contraseña) · borrar |
| POST | `/api/uploads` | subir archivo (portada/PDF) → `{ url }` |

Roles: `admin`, `bibliotecario`, `profesor`, `lector`/`user`. Subida = admin/bibliotecario/profesor · borrado = admin/bibliotecario.
