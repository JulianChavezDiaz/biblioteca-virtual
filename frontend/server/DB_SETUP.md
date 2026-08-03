## Configuración del Proyecto en Nueva Máquina

### Opción 1: Inicialización Automática ✅ (Recomendado)

La base de datos se **crea automáticamente** al iniciar el servidor.

**Requisitos:**
1. PostgreSQL instalado y ejecutándose
2. Variables de entorno configuradas

**Pasos:**

```bash
# 1. Instalar dependencias
cd server
npm install

# 2. Crear archivo .env en la carpeta server/
# Ejemplo de contenido:
# DB_HOST=localhost
# DB_PORT=5432
# DB_NAME=biblioteca
# DB_USER=postgres
# DB_PASSWORD=postgres
# JWT_SECRET=tu_secreto_aqui
# PORT=4000

# 3. Iniciar servidor (creará BD automáticamente)
npm start

# Salida esperada:
# 🔧 Inicializando base de datos...
# ✓ Conectado a PostgreSQL
# 📁 Creando base de datos 'biblioteca'...
# ✓ Base de datos 'biblioteca' creada
# ✓ Schema creado exitosamente
# ✅ Backend escuchando en http://localhost:4000
# ✓ Conexión a PostgreSQL OK
```

---

### Opción 2: Inicialización Manual

Si prefieres controlar manualmente la creación:

```bash
# 1. Conectarse a PostgreSQL
psql -U postgres

# 2. Ejecutar el script de inicialización
\i migration/setup_local_postgres.sql

# 3. Verificar que se creó correctamente
\dt  # Listar tablas

# 4. Iniciar el servidor
cd server && npm start
```

---

### Configuración del .env

Crea un archivo `.env` en la carpeta `server/`:

```env
# Base de datos
DB_HOST=localhost
DB_PORT=5432
DB_NAME=biblioteca
DB_USER=postgres
DB_PASSWORD=postgres

# Servidor
PORT=4000

# Seguridad
JWT_SECRET=tu_clave_secreta_segura_aqui_minimo_32_caracteres

# CORS
CORS_ORIGIN=http://localhost:3000,http://localhost:5173,http://localhost:8080
```

---

### Solución de Problemas

**Error: "ECONNREFUSED - PostgreSQL no está escuchando"**
- Verifica que PostgreSQL esté ejecutándose
- Comprueba las credenciales en .env

**Error: "La base de datos existe pero las tablas no"**
- Elimina la BD: `DROP DATABASE biblioteca;`
- Reinicia el servidor para que se recrece con las tablas

**Error: "FATAL: password authentication failed"**
- Verifica la contraseña en .env
- Usa: `psql -U postgres -c "SELECT 1"` para probar

---

### Usuarios por Defecto

Se crea automáticamente:
- **Email:** admin@biblioteca.com
- **Contraseña:** password
- **Rol:** admin

⚠️ **Cambia la contraseña en producción**

---

### Archivos Modificados

- `server/db-init.js` - Script de inicialización automática
- `server/server.js` - Integración con el servidor
