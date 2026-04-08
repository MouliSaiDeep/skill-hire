# Stage 1: Build the Flutter web application
FROM ghcr.io/cirruslabs/flutter:stable AS builder
WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get
COPY . .
RUN flutter build web --release

# Stage 2: Serve with Nginx (OpenShift Unprivileged Version)
FROM nginxinc/nginx-unprivileged:alpine
COPY --from=builder /app/build/web /usr/share/nginx/html

# Custom Nginx configuration for SPA routing
# (This unprivileged image natively expects 8080)
RUN echo 'server { \
 listen 8080; \
 server_name localhost; \
 root /usr/share/nginx/html; \
 index index.html; \
 location / { \
 try_files $uri $uri/ /index.html; \
 } \
}' > /etc/nginx/conf.d/default.conf

EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]