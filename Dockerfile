# --- Etapa 1: Construcción del Sitio Docusaurus ---
# Usamos una imagen de Node.js para construir el proyecto
FROM node:lts-alpine as builder

# Establecemos el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copiamos package.json y package-lock.json para instalar dependencias
COPY package.json package-lock.json ./

# Instalamos las dependencias de Node.js
RUN npm install

# Copiamos el resto del código fuente del proyecto
COPY . .

# Construimos el proyecto Docusaurus
# Esto creará la carpeta 'build/' dentro de /app
RUN npm run build

# --- Etapa 2: Servir el Sitio con NGINX ---
# Usamos una imagen de NGINX limpia y estable
FROM nginx:stable-alpine

# Copiar nuestra configuración de NGINX personalizada
# Asegúrate que tu nginx.conf tiene 'root /usr/share/nginx/html;'
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Eliminar la configuración por defecto de NGINX
RUN rm /etc/nginx/conf.d/default.conf

# Copiar los archivos estáticos generados desde la etapa 'builder'
COPY --from=builder /app/build /usr/share/nginx/html/

# Exponer el puerto 80 (puerto por defecto de NGINX dentro del contenedor)
EXPOSE 80

# Comando para que NGINX se ejecute en primer plano
# Esto es crucial para que el contenedor permanezca activo
ENTRYPOINT ["nginx", "-g", "daemon off;"]