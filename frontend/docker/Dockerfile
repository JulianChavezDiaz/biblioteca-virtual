# Usar imagen oficial de Flutter
FROM ghcr.io/cirruslabs/flutter:stable

# Establecer directorio de trabajo
WORKDIR /app

# Copiar archivos de configuración
COPY pubspec.yaml pubspec.lock ./

# Instalar dependencias
RUN flutter pub get

# Copiar código fuente
COPY . .

# Habilitar Flutter web
RUN flutter config --enable-web

# Construir aplicación web
RUN flutter build web --release

# Usar nginx para servir la aplicación
FROM nginx:alpine

# Copiar archivos construidos
COPY --from=0 /app/build/web /usr/share/nginx/html

# Copiar configuración de nginx
COPY docker/nginx.conf /etc/nginx/nginx.conf

# Exponer puerto
EXPOSE 80

# Comando por defecto
CMD ["nginx", "-g", "daemon off;"]