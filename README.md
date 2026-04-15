# Skill Hire

A full-stack **freelance skills marketplace** where clients can post requirements and hire skilled freelancers. The platform features a cross-platform **Flutter** frontend and a **Java Spring Boot** REST API backend, fully containerised with Docker and deployed to **Red Hat OpenShift** via an automated **Jenkins** CI/CD pipeline.

---

## Table of Contents

- [Overview](#overview)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Local Development with Docker Compose](#local-development-with-docker-compose)
  - [Running Services Individually](#running-services-individually)
- [Environment Variables](#environment-variables)
- [CI/CD Pipeline](#cicd-pipeline)
- [Deployment (OpenShift)](#deployment-openshift)
- [API Overview](#api-overview)
- [Contributors](#contributors)

---

## Overview

Skill Hire bridges the gap between clients looking for skilled professionals and freelancers looking for work. Users can:

- Register and log in as a **client** or a **freelancer**
- Browse and search available skills and profiles
- Post job requirements and receive applications
- Manage ongoing engagements through a dedicated dashboard

The backend exposes a RESTful API consumed by the Flutter frontend, which runs on Android, iOS, and Web from a single Dart codebase.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter (Dart) |
| Backend | Java 17, Spring Boot, Maven |
| Database | MySQL / H2 (dev) |
| Containerisation | Docker, Docker Compose |
| CI/CD | Jenkins |
| Container Registry | Docker Hub (`moulisaideep/skill-hire`) |
| Cloud Deployment | Red Hat OpenShift (Kubernetes) |
| Infrastructure Config | Kubernetes YAML manifests |

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                        Client Device                     │
│               Flutter App  (port 3000 → 8080)            │
└────────────────────────┬────────────────────────────────┘
                         │  HTTP / REST
┌────────────────────────▼────────────────────────────────┐
│              Spring Boot Backend  (port 8080)            │
│         REST Controllers → Services → Repositories       │
└────────────────────────┬────────────────────────────────┘
                         │  JDBC / JPA
                    ┌────▼────┐
                    │   DB    │
                    └─────────┘

Both services run in the same Docker bridge network: skillhire-net
```

In production, both services run as separate **OpenShift Deployments** exposed via **Routes**, orchestrated with `kubectl` through the Jenkins pipeline.

---

## Project Structure

```
skill-hire/
├── skill_hire/              # Spring Boot backend
│   ├── src/
│   │   ├── main/java/       # Controllers, Services, Repositories, Models
│   │   └── resources/       # application.properties
│   ├── Dockerfile
│   ├── pom.xml
│   └── .env                 # Environment variables (not committed)
│
├── frontend/                # Flutter frontend
│   ├── lib/
│   │   ├── screens/         # UI screens
│   │   ├── models/          # Data models
│   │   ├── services/        # API service layer
│   │   └── main.dart
│   ├── Dockerfile
│   └── pubspec.yaml
│
├── openshift/               # Kubernetes / OpenShift manifests
│   ├── skill-hire-deployment.yaml
│   ├── skill-hire-service.yaml
│   ├── skill-hire-route.yaml
│   ├── frontend-deployment.yaml
│   ├── frontend-service.yaml
│   └── frontend-route.yaml
│
├── Jenkinsfile              # CI/CD pipeline definition
├── docker-compose.yml       # Local multi-service orchestration
└── .gitignore
```

---

## Getting Started

### Prerequisites

| Tool | Version |
|---|---|
| Java | 17+ |
| Maven | 3.8+ |
| Flutter | 3.x |
| Docker | 24+ |
| Docker Compose | v2 |

### Local Development with Docker Compose

This is the fastest way to run the full stack locally.

```bash
# 1. Clone the repository
git clone https://github.com/MouliSaiDeep/skill-hire.git
cd skill-hire

# 2. Add environment variables (see Environment Variables section)
cp skill_hire/.env.example skill_hire/.env
# Edit skill_hire/.env with your values

# 3. Build and start both services
docker compose up --build

# Backend is available at: http://localhost:8080
# Frontend is available at: http://localhost:3000
```

To stop:

```bash
docker compose down
```

### Running Services Individually

**Backend (Spring Boot)**

```bash
cd skill_hire
mvn clean package -DskipTests
java -jar target/*.jar
# Runs on http://localhost:8080
```

**Frontend (Flutter)**

```bash
cd frontend
flutter pub get
flutter run
# For web: flutter run -d chrome
```

---

## Environment Variables

Create a `.env` file inside the `skill_hire/` directory. The following variables are required:

```env
# Database
DB_URL=jdbc:mysql://localhost:3306/skillhire
DB_USERNAME=your_db_user
DB_PASSWORD=your_db_password

# JWT
JWT_SECRET=your_jwt_secret_key
JWT_EXPIRY_MS=86400000

# Server
SERVER_PORT=8080
```

> **Never commit `.env` to version control.** It is listed in `.gitignore`.

---

## CI/CD Pipeline

The `Jenkinsfile` at the root defines a 4-stage automated pipeline triggered on every push to `main`:

```
┌──────────────────┐     ┌───────────────────────┐     ┌──────────────────────────┐     ┌─────────────────────┐
│  Build Backend   │────▶│ Docker Build & Push    │────▶│ Docker Build & Push      │────▶│  Deploy to OpenShift │
│  mvn clean pkg   │     │ Backend → Docker Hub   │     │ Frontend → Docker Hub    │     │  kubectl apply       │
└──────────────────┘     └───────────────────────┘     └──────────────────────────┘     └─────────────────────┘
```

**Stage details:**

**1. Build Backend** — runs `mvn clean package -DskipTests` inside `skill_hire/` to produce the JAR.

**2. Docker Build & Push Backend** — builds the backend Docker image, tags it with both `latest` and the Jenkins `BUILD_NUMBER`, and pushes both tags to Docker Hub as `moulisaideep/skill-hire`.

**3. Docker Build & Push Frontend** — same process for the Flutter web frontend, pushed as `moulisaideep/skill-hire-frontend`.

**4. Deploy to OpenShift** — authenticates to the OpenShift cluster and applies all six Kubernetes manifests from the `openshift/` directory (deployments, services, routes for both backend and frontend), then triggers rolling restarts to pick up the new images.

**Required Jenkins credentials:**

| Credential ID | Type | Purpose |
|---|---|---|
| `dockerhub-id` | Username/Password | Push images to Docker Hub |
| `openshift-credentials-id` | Token / Kubeconfig | Authenticate to OpenShift |

---

## Deployment (OpenShift)

The app is deployed to **Red Hat OpenShift** on Azure (`api.rm3.7wse.p1.openshiftapps.com`) in the namespace `23mh1a05l8-dev`.

Each service has three Kubernetes resources:

| Resource | Backend | Frontend |
|---|---|---|
| Deployment | `skill-hire-deployment.yaml` | `frontend-deployment.yaml` |
| Service | `skill-hire-service.yaml` | `frontend-service.yaml` |
| Route (public URL) | `skill-hire-route.yaml` | `frontend-route.yaml` |

To manually apply manifests:

```bash
kubectl apply -f openshift/ -n 23mh1a05l8-dev
```

To trigger a rolling restart without reapplying manifests:

```bash
kubectl rollout restart deployment/skill-hire-deployment -n 23mh1a05l8-dev
kubectl rollout restart deployment/frontend-deployment -n 23mh1a05l8-dev
```

---

## API Overview

All endpoints are served by the Spring Boot backend on port `8080`. Base URL in production is exposed via the OpenShift Route.

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/auth/register` | Register a new user (client or freelancer) |
| `POST` | `/api/auth/login` | Login and receive a JWT token |
| `GET` | `/api/users/{id}` | Get a user profile |
| `GET` | `/api/jobs` | List all posted jobs |
| `POST` | `/api/jobs` | Create a new job posting (client) |
| `GET` | `/api/jobs/{id}` | Get details of a specific job |
| `POST` | `/api/jobs/{id}/apply` | Apply to a job (freelancer) |
| `GET` | `/api/skills` | List all available skills |
| `GET` | `/api/freelancers` | Browse freelancer profiles |

> Authentication uses **JWT Bearer tokens**. Include the token in the `Authorization` header:
> ```
> Authorization: Bearer <your_token>
> ```

---

## Contributors

| Name | Role | GitHub |
|---|---|---|
| MouliSaiDeep | Flutter Frontend & Docker | [@MouliSaiDeep](https://github.com/MouliSaiDeep) |
| Nithin Datta Attili | Backend & DevOps | [@Nithin2745](https://github.com/Nithin2745) |
| Rishi Pediredla | Frontend & AWS SES | [@Rishi1435](https://github.com/Rishi1435) |

---

> Built with Flutter, Spring Boot, Docker, Jenkins, and OpenShift.
