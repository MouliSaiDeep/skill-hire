# Stage 1:build with maven
FROM maven:3.9.4-eclipse-temurin-21 AS builder
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: run the application
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
EXPOSE 8080
RUN useradd -r appuser && chown -R appuser:appuser /app
USER appuser
ENTRYPOINT ["java", "-jar", "app.jar"]