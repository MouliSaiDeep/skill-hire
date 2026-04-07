# File: frontend/Dockerfile (CREATE THIS FILE)
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
 listen 80; \
 server_name localhost; \
 root /usr/share/nginx/html; \
 index index.html; \
 location / { \
 try_files $uri $uri/ /index.html; \
 } \
}' > /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]