# Cambios en el Frontend: de Supabase a API HTTP

Explicación de cómo se migró la app Flutter para que deje de usar **Supabase**
directamente y en su lugar hable con un **backend propio (Next.js + PostgreSQL)**
por **HTTP (REST)**.

---

## 1. La idea general (el "antes y después")

**Antes:** la app Flutter se conectaba *directamente* a Supabase usando el paquete
`supabase_flutter`. Cada pantalla hacía consultas a la base de datos y a la
autenticación de Supabase por su cuenta.

```
[ Flutter ]  ──►  [ Supabase (base de datos + auth + storage) ]
```

**Ahora:** la app habla con un backend intermedio por HTTP. El backend es quien
habla con PostgreSQL. La app ya **no sabe nada de la base de datos**, solo llama
"endpoints" (URLs).

```
[ Flutter ]  ──HTTP──►  [ Backend Next.js ]  ──►  [ PostgreSQL ]
```

**Ventaja clave:** el backend devuelve el JSON con los **mismos nombres de campos**
que usaba Supabase (en `snake_case`, ej. `cover_url`, `created_at`), por eso los
modelos (`BookModel.fromJson`, etc.) **no se tuvieron que cambiar**.

---

## 2. La nueva "capa de API" — `lib/data/api/`

Se creó una carpeta nueva con 4 archivos que son el corazón de la comunicación:

| Archivo | Qué hace |
|---|---|
| `api_config.dart` | Guarda la **URL base** del backend (`http://localhost:4000/api`). Se puede cambiar al compilar con `--dart-define=API_BASE_URL=...` |
| `api_client.dart` | El **cliente HTTP** (usa `dio`). Hace GET/POST/PUT/PATCH/DELETE, **adjunta el token** en cada petición y traduce los errores. |
| `token_storage.dart` | Guarda el **token JWT** en el dispositivo (`shared_preferences`) para mantener la sesión. |
| `api_exception.dart` | Un tipo de error simple con el mensaje que devuelve el backend. |

### ¿Cómo funciona el `ApiClient`?
1. Cuando inicias sesión, el backend devuelve un **token JWT**. El cliente lo guarda.
2. En **cada petición**, el cliente agrega ese token en la cabecera
   `Authorization: Bearer <token>`. Así el backend sabe quién eres y qué permisos tienes.
3. Si el backend responde con error, lo convierte en un `ApiException` con un mensaje claro.

---

## 3. Los servicios — `lib/data/services/`

Antes cada servicio usaba `Supabase.instance.client`. Ahora usan el `ApiClient`.
El **nombre público de los métodos no cambió**, así que las pantallas casi no se tocaron.

| Servicio | Antes (Supabase) | Ahora (API) |
|---|---|---|
| `supabase_auth_service.dart` | `auth.signInWithPassword(...)` | `POST /auth/login`, `POST /auth/register`, sesión con JWT |
| `book_service.dart` (nuevo) | `client.from('books')...` | `GET/POST/PUT/DELETE /books` |
| `video_service.dart` (nuevo) | `client.from('videos')...` | `.../videos` |
| `category_service.dart` (nuevo) | `client.from('categories')...` | `.../categories` |
| `favorites_service.dart` | `client.from('favorites')...` | `.../favorites` |
| `stats_service.dart` | `client.from('book_stats')...` + RPC | `.../stats/...`, `.../books/:id/open` |
| `support_service.dart` | `client.from('requests')...` | `.../support-requests` |
| `user_service.dart` (nuevo) | `client.from('users')...` | `.../users` |
| `upload_service.dart` (nuevo) | `client.storage.upload(...)` | `POST /uploads` |

> Nota: la clase de auth se sigue llamando `SupabaseAuthService` (para no tocar
> todos los imports), pero **por dentro ya no usa Supabase**.

---

## 4. Ejemplos concretos (antes → después)

### a) Leer libros
**Antes:**
```dart
final response = await Supabase.instance.client
    .from('books')
    .select()
    .order('created_at', ascending: false);
```
**Ahora:**
```dart
final response = await BookService().getBooks();
```
Por dentro, `getBooks()` hace: `GET http://localhost:4000/api/books`

### b) Iniciar sesión
**Antes:**
```dart
await Supabase.instance.client.auth.signInWithPassword(
  email: email, password: password,
);
```
**Ahora:**
```dart
await SupabaseAuthService().login(email, password);
// -> POST /auth/login  ->  { token, user }  ->  se guarda el token
```

### c) Saber quién es el usuario actual
**Antes:** `Supabase.instance.client.auth.currentUser`
**Ahora:** `SupabaseAuthService().currentUser` (se llena al iniciar sesión o al
restaurar la sesión con el token guardado).

### d) Favoritos
**Antes:**
```dart
await Supabase.instance.client.from('favorites').insert({
  'user_id': user.id, 'book_id': bookId,
});
```
**Ahora:**
```dart
await FavoritesService().addToFavorites(bookId);
// El backend ya sabe el user_id por el token; no hay que mandarlo.
```

### e) Subir archivos (portadas / PDFs)
**Antes:** `Supabase.instance.client.storage.from('Libros_digitales').uploadBinary(...)`
**Ahora:**
```dart
final url = await UploadService().upload(bytes, nombreArchivo);
// -> POST /uploads (multipart) -> devuelve la URL pública del archivo
```

---

## 5. Conceptos importantes que cambiaron

### Autenticación: de "sesión de Supabase" a "token JWT"
- Al hacer login, el backend genera un **JWT** (un texto firmado que contiene tu id,
  email y rol) y lo devuelve. La app lo guarda en `shared_preferences`.
- Ese token se manda en cada petición. Al reabrir la app, se valida el token contra
  `GET /auth/me` para restaurar la sesión.
- **Los permisos (rol) viajan dentro del token.** Por eso, si cambias el rol de un
  usuario en la BD, debe **cerrar sesión y volver a entrar** para que el token nuevo
  tenga el rol actualizado.

### Los modelos NO cambiaron
Como el backend responde en `snake_case` igual que Supabase, `BookModel.fromJson`,
`VideoModel.fromJson`, etc. siguen funcionando sin tocarlos.

### Ya no hay "tiempo real" (realtime)
Supabase permitía escuchar cambios en vivo (`.stream()`). El backend HTTP no tiene
eso, así que las solicitudes de soporte ahora se **cargan una vez** (se refrescan al
reabrir la pantalla) en vez de actualizarse solas.

### Se eliminó todo lo de Supabase
- Se quitó `supabase_flutter` del `pubspec.yaml`.
- Se borraron archivos que ya no aplican: `database_seeder`, `test_users_service`,
  `debug_service`, `debug_video_widget`, `main_dev` (el sembrado de datos y usuarios
  ahora es tarea del backend).
- `main.dart` ya no inicializa Supabase; en su lugar carga el token guardado.

---

## 6. Resumen visual del flujo de una acción

Ejemplo: el usuario abre la app y ve la lista de libros.

```
1. main.dart          -> ApiClient.init()  (carga el token guardado)
2. LibraryTab         -> BookService().getBooks()
3. BookService        -> ApiClient.get('/books')
4. ApiClient (dio)    -> GET http://localhost:4000/api/books   (+ token)
5. Backend Next.js    -> consulta PostgreSQL con Prisma
6. Backend            -> responde JSON snake_case
7. ApiClient          -> devuelve la lista de mapas
8. BookModel.fromJson -> convierte cada mapa en un objeto (sin cambios)
9. La UI              -> muestra los libros
```

---

## 7. ¿Qué archivos se tocaron en el frontend?

- **Nuevos:** `lib/core/config/api_config.dart`, toda la carpeta `lib/data/api/`,
  y los servicios `book_service`, `video_service`, `category_service`,
  `user_service`, `upload_service`.
- **Reescritos por dentro:** los servicios `supabase_auth_service`, `favorites_service`,
  `stats_service`, `support_service`.
- **Pantallas ajustadas:** login, registro, reset de contraseña, home de usuario,
  panel admin, detalle de libro, lector, gestión de usuarios, formularios de alta,
  vistas por categoría, y varios widgets. En casi todas el cambio fue solo reemplazar
  la llamada a Supabase por la llamada al servicio correspondiente.
- **Borrados:** `database_seeder`, `test_users_service`, `debug_service`,
  `debug_video_widget`, `main_dev`.
