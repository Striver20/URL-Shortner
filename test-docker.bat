@echo off
REM URL Shortener - Docker Test Script for Windows
echo ==========================================
echo   URL Shortener - Docker Test Script
echo ==========================================
echo.

REM Check if Docker is installed
docker --version >nul 2>&1
if errorlevel 1 (
    echo Docker is not installed. Please install Docker Desktop first.
    exit /b 1
)

REM Check if Docker Compose is installed
docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo Docker Compose is not installed. Please install Docker Compose first.
    exit /b 1
)

echo 1. Starting Docker containers...
docker-compose up -d --build

echo.
echo 2. Waiting for services to be ready...
timeout /t 30 /nobreak >nul

echo.
echo 3. Checking service status...
docker-compose ps

echo.
echo ==========================================
echo   Summary
echo ==========================================
echo.
echo Frontend:  http://localhost:3000
echo Backend:   http://localhost:8080
echo Swagger:   http://localhost:8080/swagger-ui.html
echo Health:    http://localhost:8080/actuator/health
echo.
echo To view logs:
echo   docker-compose logs -f
echo.
echo To stop services:
echo   docker-compose down
echo.

pause

