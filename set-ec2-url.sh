#!/bin/bash

# Script to set the correct base URL for AWS EC2 deployment
# Replace YOUR_EC2_PUBLIC_IP with your actual EC2 public IP address

echo "Setting up URL shortener for AWS EC2 deployment..."
echo ""

# Get EC2 public IP (if running on EC2)
if command -v curl &> /dev/null; then
    EC2_PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null)
    if [ $? -eq 0 ] && [ ! -z "$EC2_PUBLIC_IP" ]; then
        echo "Detected EC2 public IP: $EC2_PUBLIC_IP"
        BASE_URL="http://$EC2_PUBLIC_IP:8080"
    else
        echo "Could not auto-detect EC2 public IP. Please enter it manually:"
        read -p "Enter your EC2 public IP: " EC2_PUBLIC_IP
        BASE_URL="http://$EC2_PUBLIC_IP:8080"
    fi
else
    echo "Please enter your EC2 public IP address:"
    read -p "Enter your EC2 public IP: " EC2_PUBLIC_IP
    BASE_URL="http://$EC2_PUBLIC_IP:8080"
fi

echo ""
echo "Setting base URL to: $BASE_URL"
echo ""

# Update application.properties
sed -i "s|app.base-url=\${APP_BASE_URL:http://localhost:8080}|app.base-url=$BASE_URL|g" backend/src/main/resources/application.properties

echo "✅ Updated application.properties with base URL: $BASE_URL"
echo ""
echo "Next steps:"
echo "1. Rebuild your application: mvn clean package"
echo "2. Restart your application"
echo "3. Test the shortened URLs - they should now use your EC2 IP instead of localhost"
echo ""
echo "Alternative: You can also set the APP_BASE_URL environment variable:"
echo "export APP_BASE_URL=$BASE_URL"
