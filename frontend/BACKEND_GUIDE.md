# Guía del backend local de la biblioteca

## Objetivo
Este proyecto incluye un backend simple en Node.js para soportar:
- registro e inicio de sesión de usuarios,
- consulta de libros,
- creación de libros desde la app o desde pruebas manuales,
- conexión a una base de datos PostgreSQL local.

## Tecnologías
- Node.js
- Express
- PostgreSQL
- JWT
- bcryptjs
- pg

## Estructura relevante
- server/server.js: punto de entrada del backend
- server/.env: variables de entorno
- server/package.json: dependencias del backend
- migration/: scripts SQL para crear o adaptar tablas

## Requisitos previos
Asegúrate de tener instalado:
- Node.js
- PostgreSQL
- npm

## 1. Clonar o abrir el proyecto
```bash
cd ruta/del/proyecto/biblioteca-frontend-desarrollo
```

## 2. Instalar dependencias del backend
```bash
cd server
npm install
```

## 3. Configurar variables de entorno
El archivo server/.env debe tener algo como esto:
```env
PORT=4000
DB_HOST=localhost
DB_PORT=5434
DB_NAME=biblioteca
DB_USER=postgres
DB_PASSWORD=12345
JWT_SECRET=supersecret
```

> Ajusta los valores según tu instalación local de PostgreSQL.

## 4. Crear o preparar la base de datos
Si la base aún no existe, crea la base y las tablas con los scripts en la carpeta migration.

Ejemplo para PostgreSQL:
```bash
psql -U postgres -h localhost -p 5434 -d postgres -f migration/setup_local_postgres.sql
```

Si tu base ya existe y solo necesitas ajustar la tabla users:
```sql
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS password_hash text;
```

## 5. Ejecutar el backend
```bash
cd server
node server.js
```

Si todo está bien, deberías ver algo como:
```bash
Servidor escuchando en puerto 4000
Conexión a PostgreSQL OK
```

## 6. Probar el backend con Postman

### Registro
- Método: POST
- URL: http://localhost:4000/api/auth/register
- Body (raw, JSON):
```json
{
  "email": "test@correo.com",
  "password": "123456",
  "name": "Usuario Test"
}
```

### Login
- Método: POST
- URL: http://localhost:4000/api/auth/login
- Body (raw, JSON):
```json
{
  "email": "test@correo.com",
  "password": "123456"
}
```

### Obtener libros
- Método: GET
- URL: http://localhost:4000/api/books

### Crear un libro
- Método: POST
- URL: http://localhost:4000/api/books
- Headers:
```text
Authorization: Bearer <token>
```
- Body (raw, JSON):
```json
{
  "title": "El principito",
  "author": "Antoine de Saint-Exupéry",
  "description": "Una obra clásica",
  "file_url": "https://example.com/el-principito.pdf",
  "cover_url": "https://example.com/el-principito.jpg",
  "format": "pdf",
  "category": "Literatura",
  "isbn": "978-1234567890",
  "year": 1943
}
```

## 7. Comandos útiles para tu compañero
### Instalar dependencias
```bash
cd server
npm install
```

### Iniciar el servidor
```bash
cd server
node server.js
```

### Probar login desde PowerShell
```powershell
$body = @{email='test@correo.com'; password='123456'} | ConvertTo-Json
Invoke-RestMethod -Method Post -Uri 'http://localhost:4000/api/auth/login' -ContentType 'application/json' -Body $body
```

### Probar obtener libros
```powershell
Invoke-RestMethod -Method Get -Uri 'http://localhost:4000/api/books'
```

## Sugerencias
- Mantener los scripts SQL en la carpeta migration para poder recrear la base en otra máquina.
- No hardcodear credenciales; usar .env.
- Si el proyecto crece, separar rutas, controladores y servicios para que el backend sea más limpio.
- Añadir validaciones y manejo de errores más robusto.
- Considerar mover la lógica de autenticación a un servicio propio si se amplía el proyecto.

## Recomendación final
Este backend ya sirve como base funcional para empezar a trabajar, pero si se va a escalar, conviene reorganizarlo en carpetas como:
- routes/
- controllers/
- services/
- middlewares/
