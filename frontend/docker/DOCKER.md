# Biblioteca Virtual Yavirac - Docker

## Construcción y Ejecución

### Opción 1: Docker Compose (Recomendado)
```bash
# Ir a carpeta docker
cd docker

# Construir y ejecutar
docker-compose up --build

# En segundo plano
docker-compose up -d --build

# Parar
docker-compose down
```

### Opción 2: Docker directo
```bash
# Construir imagen
docker build -t biblioteca-yavirac .

# Ejecutar contenedor
docker run -p 8080:80 biblioteca-yavirac
```

## Acceso
- Aplicación: http://localhost:8080

## Configuración de Producción

### Variables de Entorno
Crear archivo `.env`:
```
SUPABASE_URL=tu_url_supabase
SUPABASE_ANON_KEY=tu_key_supabase
```

### Deploy en Servidor
```bash
# Clonar repositorio
git clone https://github.com/Alyzon23/Bibliotecavirtual.git
cd Bibliotecavirtual

# Configurar variables
cp .env.example .env
# Editar .env con tus valores

# Ejecutar
docker-compose up -d --build
```

## Notas
- La aplicación se construye para producción automáticamente
- Nginx sirve los archivos estáticos con compresión gzip
- Cache configurado para assets estáticos