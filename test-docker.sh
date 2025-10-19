#!/bin/bash

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=========================================="
echo "  URL Shortener - Docker Test Script"
echo "=========================================="
echo ""

# Function to check if a service is running
check_service() {
    local service=$1
    local port=$2
    local max_attempts=30
    local attempt=1

    echo -n "Checking $service on port $port... "
    
    while [ $attempt -le $max_attempts ]; do
        if nc -z localhost $port 2>/dev/null; then
            echo -e "${GREEN}✓ Running${NC}"
            return 0
        fi
        sleep 2
        attempt=$((attempt + 1))
    done
    
    echo -e "${RED}✗ Failed${NC}"
    return 1
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker is not installed. Please install Docker first.${NC}"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}Docker Compose is not installed. Please install Docker Compose first.${NC}"
    exit 1
fi

echo "1. Starting Docker containers..."
docker-compose up -d --build

echo ""
echo "2. Waiting for services to be ready..."
echo ""

# Check each service
check_service "MySQL" 3306
check_service "Redis" 6379
check_service "Backend" 8080
check_service "Frontend" 3000

echo ""
echo "3. Testing service health..."
echo ""

# Test backend health
echo -n "Testing backend health endpoint... "
if curl -s http://localhost:8080/actuator/health | grep -q "UP"; then
    echo -e "${GREEN}✓ Healthy${NC}"
else
    echo -e "${RED}✗ Unhealthy${NC}"
fi

# Test frontend
echo -n "Testing frontend... "
if curl -s http://localhost:3000 | grep -q "html"; then
    echo -e "${GREEN}✓ Accessible${NC}"
else
    echo -e "${RED}✗ Not accessible${NC}"
fi

# Test Redis
echo -n "Testing Redis connection... "
if docker exec urlshortener-redis redis-cli ping | grep -q "PONG"; then
    echo -e "${GREEN}✓ Connected${NC}"
else
    echo -e "${RED}✗ Connection failed${NC}"
fi

# Test MySQL
echo -n "Testing MySQL connection... "
if docker exec urlshortener-mysql mysqladmin ping -h localhost -u root -prootpassword 2>/dev/null | grep -q "alive"; then
    echo -e "${GREEN}✓ Connected${NC}"
else
    echo -e "${RED}✗ Connection failed${NC}"
fi

echo ""
echo "=========================================="
echo "  Summary"
echo "=========================================="
echo ""
echo "✅ Frontend:  http://localhost:3000"
echo "✅ Backend:   http://localhost:8080"
echo "✅ Swagger:   http://localhost:8080/swagger-ui.html"
echo "✅ Health:    http://localhost:8080/actuator/health"
echo ""
echo "To view logs:"
echo "  docker-compose logs -f"
echo ""
echo "To stop services:"
echo "  docker-compose down"
echo ""

