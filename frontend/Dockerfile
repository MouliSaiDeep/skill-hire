# Stage 1: Build the Flutter web application
FROM ghcr.io/cirruslabs/flutter:stable AS builder
WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get
COPY . .
RUN flutter build web --release

# Stage 2: Serve with Nginx
FROM nginx:alpine
COPY --from=builder /app/build/web /usr/share/nginx/html

# Custom Nginx configuration for SPA routing
RUN echo 'server { \
 listen 8080; \
 server_name localhost; \
 root /usr/share/nginx/html; \
 index index.html; \
 location / { \
 try_files $uri $uri/ /index.html; \
 } \
}' > /etc/nginx/conf.d/default.conf

# 1. Remove the default "user" directive (OpenShift forces its own random user)
RUN sed -i 's/user  nginx;//g' /etc/nginx/nginx.conf

# 2. Move the PID file to the /tmp directory so OpenShift can write to it
RUN sed -i 's/pid        \/var\/run\/nginx.pid;/pid        \/tmp\/nginx.pid;/g' /etc/nginx/nginx.conf

# 3. Grant full write access to Nginx's cache and log folders
RUN chmod -R 777 /var/cache/nginx /var/run /var/log/nginx /etc/nginx/conf.d

EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]