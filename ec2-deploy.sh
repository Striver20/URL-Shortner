#!/bin/bash

# EC2 Deployment Script for URL Shortener
# Run this script on your EC2 instance after SSH connection

echo "========================================="
echo "URL Shortener - EC2 Deployment Script"
echo "========================================="
echo ""

# Step 1: Clone repository
echo "Step 1: Cloning repository from GitHub..."
git clone https://github.com/Striver20/URL-Shortner.git
cd URL-Shortner || exit 1

echo "✓ Repository cloned successfully"
echo ""

# Step 2: Start Docker services
echo "Step 2: Starting Docker services (this will take 5-10 minutes)..."
echo "Building and starting MySQL, Redis, Backend, and Frontend..."
docker-compose up -d --build

echo ""
echo "Waiting for services to become healthy..."
sleep 30

# Step 3: Check service status
echo ""
echo "Step 3: Checking service status..."
docker-compose ps

echo ""
echo "========================================="
echo "Deployment Complete!"
echo "========================================="
echo ""
echo "Your application is now live at:"
echo "  Frontend:  http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):3000"
echo "  Backend:   http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080"
echo "  Swagger:   http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080/swagger-ui.html"
echo "  Health:    http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080/actuator/health"
echo ""
echo "To view logs: docker-compose logs -f"
echo "To stop: docker-compose down"
echo ""

