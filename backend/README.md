# Biblioteca Digital — Backend (Next.js + Postgres)

API REST que reemplaza a Supabase para la app Flutter **Biblioteca Digital**.
Devuelve JSON en `snake_case` con la misma forma que devolvía Supabase, por lo que
los modelos Flutter (`BookModel.fromJson`, `VideoModel.fromJson`, etc.) funcionan
**sin cambios**. Auth propia con JWT + bcrypt.

- **Next.js 15** (App Router, route handlers bajo `src/app/api`)
- **Prisma** ORM sobre **PostgreSQL**
- **JWT** (`jsonwebtoken`) + **bcryptjs** para autenticación

---

## Requisitos

- Node.js 20+ (probado con 22)
- PostgreSQL 14+ (local, Docker, o un Postgres gestionado)

## Puesta en marcha

```bash
# 1. Variables de entorno
cp .env.example .env        # y edita JWT_SECRET / DATABASE_URL si hace falta

# 2. Levantar Postgres
#    Opción A — Docker (usa las credenciales de .env tal cual):
docker compose up -d
#    Opción B — Postgres local: crea la BD y ajusta DATABASE_URL en .env, p.ej.:
#    createdb biblioteca

# 3. Dependencias
npm install

# 4. Crear las tablas a partir del esquema Prisma
npm run db:push

# 5. (Opcional) Datos iniciales: usuarios de prueba, categorías y un libro
npm run db:seed

# 6. Arrancar en desarrollo (http://localhost:4000)
npm run dev
```

Comprobación rápida: `GET http://localhost:4000/api/health` → `{ "status": "ok", "db": "up" }`.

## Scripts

| comando            | descripción                                  |
| ------------------ | -------------------------------------------- |
| `npm run dev`      | servidor de desarrollo en el puerto **4000** |
| `npm run build`    | build de producción (incluye type-check)     |
| `npm start`        | servir el build                              |
| `npm run db:push`  | aplica el esquema Prisma a la BD             |
| `npm run db:seed`  | siembra datos iniciales                      |
| `npm run db:studio`| explora la BD con Prisma Studio              |

## Usuarios de prueba (tras `db:seed`)

> ⚠️ Cambia estas contraseñas antes de producción.

| email                          | password   | rol            |
| ------------------------------ | ---------- | -------------- |
| admin@yavirac.edu.ec           | admin123   | admin          |
| bibliotecario@yavirac.edu.ec   | biblio123  | bibliotecario  |
| profesor@yavirac.edu.ec        | profe123   | profesor       |
| lector@yavirac.edu.ec          | lector123  | lector         |

## Endpoints

Autenticación → devuelve `{ token, user }`. El resto requieren header
`Authorization: Bearer <token>` (salvo los GET públicos de catálogo).

| método | ruta                          | descripción                              | permiso          |
| ------ | ----------------------------- | ---------------------------------------- | ---------------- |
| POST   | `/api/auth/register`          | registro                                 | público          |
| POST   | `/api/auth/login`             | login                                    | público          |
| GET    | `/api/auth/me`                | usuario del token                        | auth             |
| POST   | `/api/auth/reset-password`    | solicitar reset (pendiente email)        | público          |
| GET    | `/api/books`                  | listar libros (`?search=&category=`)     | público          |
| POST   | `/api/books`                  | crear libro                              | subida           |
| GET    | `/api/books/:id`              | detalle                                  | público          |
| PUT    | `/api/books/:id`              | editar                                   | subida           |
| DELETE | `/api/books/:id`              | borrar                                   | borrado          |
| POST   | `/api/books/:id/open`         | registrar apertura (+contador)           | auth             |
| GET    | `/api/videos`                 | listar videos                            | público          |
| POST   | `/api/videos`                 | crear video                              | subida           |
| GET/PUT/DELETE | `/api/videos/:id`     | detalle / editar / borrar                | público / subida |
| GET    | `/api/categories`             | listar categorías activas                | público          |
| POST   | `/api/categories`             | crear                                    | subida           |
| PUT/DELETE | `/api/categories/:id`     | editar / borrar lógico                   | subida / borrado |
| GET    | `/api/favorites`              | ids favoritos (`?full=1` → libros)       | auth             |
| POST   | `/api/favorites`              | agregar `{ bookId }`                      | auth             |
| GET/DELETE | `/api/favorites/:bookId`  | ¿es favorito? / quitar                   | auth             |
| GET    | `/api/support-requests`       | listar (propias o todas si staff)        | auth             |
| POST   | `/api/support-requests`       | crear `{ title, description, type }`     | auth             |
| PATCH  | `/api/support-requests/:id`   | marcar resuelto                          | staff            |
| DELETE | `/api/support-requests/:id`   | borrar                                   | dueño / staff    |
| GET    | `/api/stats/top-books`        | libros más abiertos                      | público          |
| GET    | `/api/stats/recent`           | últimos leídos del usuario               | auth             |
| POST   | `/api/reading-progress`       | guardar progreso `{ bookId, progress }`  | auth             |
| GET    | `/api/users`                  | listar usuarios                          | staff            |
| PATCH  | `/api/users/:id`              | cambiar rol                              | admin            |
| DELETE | `/api/users/:id`              | borrar usuario                           | admin            |

**Roles**: `subida` = admin/bibliotecario/profesor · `borrado`/`staff` = admin/bibliotecario · `admin` = admin.

## Siguiente paso: conectar la app Flutter

La app todavía usa `supabase_flutter`. El siguiente trabajo es reemplazar esa capa
de datos por un cliente HTTP (`dio`, ya está en `pubspec.yaml`) que apunte a esta API
y guarde el JWT en `shared_preferences`. Los modelos no cambian gracias al JSON
`snake_case`.
