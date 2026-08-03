# Guía de prueba local antes de producción

## Objetivo
Levantar el frontend y el backend en tu computadora para probar el flujo completo antes de desplegar a producción.

## Requisitos previos
- Node.js instalado
- PostgreSQL instalado y corriendo
- Git instalado
- Un editor como VS Code

## 1. Preparar la base de datos local
Asegúrate de que PostgreSQL esté corriendo.

### Crear la base de datos
```bash
psql -U postgres -h localhost -p 5434 -d postgres
```

Dentro de psql:
```sql
CREATE DATABASE biblioteca;
```

### Crear las tablas
```bash
psql -U postgres -h localhost -p 5434 -d biblioteca -f migration/setup_local_postgres.sql
```

## 2. Configurar el backend
Ve a la carpeta del backend:
```bash
cd server
```

Asegúrate de tener un archivo .env con valores correctos, por ejemplo:
```env
PORT=4000
DB_HOST=localhost
DB_PORT=5434
DB_NAME=biblioteca
DB_USER=postgres
DB_PASSWORD=12345
JWT_SECRET=supersecret
```

Instala dependencias:
```bash
npm install
```

## 3. Levantar el backend localmente
```bash
node server.js
```

Si todo está bien, verás algo como:
```bash
Servidor escuchando en puerto 4000
Conexión a PostgreSQL OK
```

## 4. Probar el backend con Postman o navegador
### Health check
- GET: http://localhost:4000/health

### Registro
- POST: http://localhost:4000/api/auth/register
```json
{
  "email": "test@correo.com",
  "password": "123456",
  "name": "Usuario Test"
}
```

### Login
- POST: http://localhost:4000/api/auth/login
```json
{
  "email": "test@correo.com",
  "password": "123456"
}
```

### Obtener libros
- GET: http://localhost:4000/api/books

### Crear un libro
- POST: http://localhost:4000/api/books
- Header:
```text
Authorization: Bearer <token>
```

## 5. Levantar el frontend localmente
Ve a la carpeta del proyecto Flutter:
```bash
cd ..
flutter pub get
flutter run
```

Si usas una configuración distinta, ajusta el puerto o la URL del backend en la app.

## 6. Probar el flujo completo del sistema
### Flujo recomendado
1. Abrir la app
2. Registrarse
3. Iniciar sesión
4. Verificar que aparecen los libros
5. Crear un libro nuevo
6. Verificar que se muestra en la lista
7. Cerrar sesión
8. Intentar entrar a una ruta protegida sin sesión

## 7. Revisar posibles errores comunes
### Error de conexión con la base
- revisa que PostgreSQL esté corriendo,
- revisa el puerto y credenciales en .env.

### Error 401 o Token requerido
- verifica que el frontend esté enviando el token en el header Authorization.

### Error al obtener libros
- revisa que la tabla books exista y tenga datos.

### Error al registrar usuario
- revisa que la tabla users tenga la columna password_hash.

## 8. Qué hacer antes de pasar a producción
Antes de desplegar, verifica:
- que el backend funcione sin errores,
- que la base tenga datos válidos,
- que el frontend consuma correctamente las rutas,
- que los errores se muestren bien,
- que no haya secretos expuestos en el código,
- que las variables de entorno estén bien definidas.

## 9. Comandos útiles de prueba local
### Backend
```bash
cd server
npm install
node server.js
```

### Frontend
```bash
flutter pub get
flutter run
```

### Probar login con PowerShell
```powershell
$body = @{email='test@correo.com'; password='123456'} | ConvertTo-Json
Invoke-RestMethod -Method Post -Uri 'http://localhost:4000/api/auth/login' -ContentType 'application/json' -Body $body
```

### Probar libros
```powershell
Invoke-RestMethod -Method Get -Uri 'http://localhost:4000/api/books'
```

## Recomendación final
Antes de mandar a producción, haz una prueba completa con:
- backend funcionando,
- base de datos local cargada,
- frontend abierto,
- registro/login/libros funcionando,
- y sin errores en consola o en la red.
