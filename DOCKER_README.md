# Docker Deployment Guide

## Prerequisites

- Docker Engine 20.10+ installed
- Docker Compose 2.0+ installed
- At least 2GB RAM available
- Ports 3000, 8080, 3306, 6379 available

## Quick Start

### 1. Build and Start All Services

```bash
docker-compose up -d --build
```

This will start:

- **MySQL** on port 3306
- **Redis** on port 6379
- **Spring Boot Backend** on port 8080
- **React Frontend** on port 3000

### 2. Check Service Status

```bash
docker-compose ps
```

### 3. View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f frontend
```

### 4. Access the Application

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8080
- **Swagger UI**: http://localhost:8080/swagger-ui.html
- **API Docs**: http://localhost:8080/api-docs

### 5. Stop Services

```bash
docker-compose down
```

### 6. Stop and Remove Volumes (Clean Start)

```bash
docker-compose down -v
```

## Service Details

### MySQL Database

- **Image**: mysql:8.0
- **Database**: urlshortener
- **Username**: urluser
- **Password**: urlpassword
- **Root Password**: rootpassword

### Redis Cache

- **Image**: redis:7-alpine
- **Max Memory**: 256MB
- **Eviction Policy**: allkeys-lru

### Backend (Spring Boot)

- **Base Image**: eclipse-temurin:17-jre-alpine
- **Build Tool**: Maven
- **Health Check**: /actuator/health
- **Connection Pool**: HikariCP (20 max connections)

### Frontend (React + Nginx)

- **Base Image**: nginx:alpine
- **Node Version**: 18
- **Build Tool**: npm
- **Reverse Proxy**: Nginx handles /api requests to backend

## Environment Variables

Copy `.env.example` to `.env` and customize if needed:

```bash
cp .env.example .env
```

## Troubleshooting

### Backend fails to start

```bash
# Check MySQL is healthy
docker-compose ps mysql

# View backend logs
docker-compose logs backend

# Restart backend
docker-compose restart backend
```

### Database connection issues

```bash
# Enter MySQL container
docker exec -it urlshortener-mysql mysql -u urluser -purlpassword

# Check if database exists
SHOW DATABASES;
USE urlshortener;
SHOW TABLES;
```

### Redis connection issues

```bash
# Test Redis connectivity
docker exec -it urlshortener-redis redis-cli ping
# Should return: PONG
```

### Port already in use

```bash
# Change ports in docker-compose.yml
ports:
  - "8081:8080"  # Change 8080 to 8081
```

## Production Deployment

### Update Base URLs

1. Edit `docker-compose.yml` and add:

```yaml
backend:
  environment:
    APP_BASE_URL: http://your-domain.com
```

2. Update frontend API calls to use production URL

### Enable SSL/TLS

1. Add Nginx reverse proxy in front
2. Use Let's Encrypt for SSL certificates
3. Update docker-compose.yml with SSL configuration

### Resource Limits

Add resource constraints:

```yaml
services:
  backend:
    deploy:
      resources:
        limits:
          cpus: "1"
          memory: 1G
        reservations:
          cpus: "0.5"
          memory: 512M
```

## Monitoring

### Check Container Stats

```bash
docker stats
```

### Health Checks

```bash
# Backend health
curl http://localhost:8080/actuator/health

# Frontend health
curl http://localhost:3000

# Redis health
docker exec urlshortener-redis redis-cli ping
```

## Backup & Restore

### Backup MySQL Data

```bash
docker exec urlshortener-mysql mysqldump -u root -prootpassword urlshortener > backup.sql
```

### Restore MySQL Data

```bash
docker exec -i urlshortener-mysql mysql -u root -prootpassword urlshortener < backup.sql
```

## Development Mode

### Hot Reload for Frontend

```bash
# Run only backend services
docker-compose up mysql redis backend -d

# Run frontend locally
cd frontend
npm start
```

### Debug Backend

Add to docker-compose.yml:

```yaml
backend:
  environment:
    JAVA_TOOL_OPTIONS: "-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005"
  ports:
    - "5005:5005"
```

## Clean Up

### Remove All Containers, Networks, and Volumes

```bash
docker-compose down -v --remove-orphans
```

### Remove Images

```bash
docker rmi urlshortner-backend urlshortner-frontend
```

### Prune Docker System

```bash
docker system prune -a --volumes
```

---

## Contact

- **GitHub**: [@Striver20](https://github.com/Striver20/URL-Shortner)
- **LinkedIn**: [Ashit Verma](https://www.linkedin.com/in/ashit-verma-6b7769337)
- **Email**: ashitverma56@gmail.com