# AWS EC2 Deployment Guide - URL Shortener

This guide walks you through deploying the URL Shortener application on AWS EC2 (free tier eligible).

## Prerequisites

- AWS Account (with billing enabled)
- Basic knowledge of AWS Console
- SSH client installed on your local machine
- Git repository URL of your project

## Cost Estimation

Using AWS Free Tier:

- **EC2 t2.micro**: FREE (750 hours/month for 12 months)
- **EBS Storage 30GB**: FREE (within 30GB limit)
- **Data Transfer**: 1GB outbound free per month
- **Estimated Monthly Cost**: $0 (within free tier limits)

After free tier expires: ~$8-10/month

## Step 1: Launch EC2 Instance

### 1.1 Access EC2 Dashboard

1. Log in to [AWS Console](https://console.aws.amazon.com/)
2. Navigate to **EC2** service (search "EC2" in the top search bar)
3. Click **Launch Instance**

### 1.2 Configure Instance

**Name and Tags:**

- Name: `url-shortener-app`

**Application and OS Images (AMI):**

- Select: **Ubuntu Server 22.04 LTS**
- Architecture: **64-bit (x86)**

**Instance Type:**

- Select: **t2.micro** (Free tier eligible - 1 vCPU, 1 GB RAM)

**Key Pair (login):**

- Click **Create new key pair**
  - Name: `url-shortener-key`
  - Key pair type: **RSA**
  - Private key format: **.pem** (for SSH) or **.ppk** (for PuTTY on Windows)
- Click **Create key pair** and save the file securely
- **Important**: Keep this file safe - you can't download it again!

**Network Settings:**

- Click **Edit**
- Auto-assign public IP: **Enable**
- Firewall (Security Groups): **Create security group**
  - Name: `url-shortener-sg`
  - Description: `Security group for URL Shortener application`

**Add Security Group Rules:**

| Type       | Protocol | Port Range | Source    | Description             |
| ---------- | -------- | ---------- | --------- | ----------------------- |
| SSH        | TCP      | 22         | My IP     | SSH access from your IP |
| HTTP       | TCP      | 80         | 0.0.0.0/0 | HTTP access             |
| HTTPS      | TCP      | 443        | 0.0.0.0/0 | HTTPS access (future)   |
| Custom TCP | TCP      | 8080       | 0.0.0.0/0 | Backend API             |
| Custom TCP | TCP      | 3000       | 0.0.0.0/0 | Frontend (optional)     |

**Configure Storage:**

- Size: **30 GB** (Free tier limit)
- Volume Type: **gp3** (or gp2)
- Delete on termination: **Yes**

**Advanced Details:**

- Keep defaults

### 1.3 Launch Instance

1. Review your configuration
2. Click **Launch Instance**
3. Wait for instance to reach **Running** state
4. Note your **Public IPv4 address** (e.g., `54.123.45.67`)

## Step 2: Connect to EC2 Instance

### 2.1 For Linux/Mac (SSH)

```bash
# Set proper permissions on key file
chmod 400 url-shortener-key.pem

# Connect to EC2
ssh -i url-shortener-key.pem ubuntu@<YOUR_PUBLIC_IP>
```

### 2.2 For Windows (PuTTY)

1. Download and install [PuTTY](https://www.putty.org/)
2. Convert .pem to .ppk using PuTTYgen (if needed)
3. Connect:
   - Host Name: `ubuntu@<YOUR_PUBLIC_IP>`
   - Port: `22`
   - Connection > SSH > Auth: Browse for your .ppk file
   - Click **Open**

### 2.3 For Windows (PowerShell with OpenSSH)

```powershell
# Connect to EC2
ssh -i url-shortener-key.pem ubuntu@<YOUR_PUBLIC_IP>
```

## Step 3: Install Dependencies

Once connected to your EC2 instance:

```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Install Docker
sudo apt install docker.io -y

# Install Docker Compose
sudo apt install docker-compose -y

# Install Git
sudo apt install git -y

# Add ubuntu user to docker group (to run docker without sudo)
sudo usermod -aG docker ubuntu

# Apply group changes (or logout and login again)
newgrp docker

# Verify installations
docker --version
docker-compose --version
git --version
```

Expected output:

```
Docker version 24.x.x
Docker Compose version 2.x.x
git version 2.34.x
```

## Step 4: Clone and Deploy Application

```bash
# Clone your repository
git clone https://github.com/YOUR_USERNAME/URL-Shortener.git
cd URL-Shortener

# Start all services
docker-compose up -d --build
```

**Build time**: 5-10 minutes (first time)

## Step 5: Verify Deployment

```bash
# Check all containers are running
docker-compose ps

# Expected output:
# NAME                     STATUS
# urlshortener-mysql       Up (healthy)
# urlshortener-redis       Up (healthy)
# urlshortener-backend     Up (healthy)
# urlshortener-frontend    Up (healthy)

# Check backend health
curl http://localhost:8080/actuator/health

# Expected: {"status":"UP"}

# View logs if needed
docker-compose logs -f backend
```

## Step 6: Access Your Application

Your application is now live!

- **Frontend**: `http://<YOUR_PUBLIC_IP>:3000`
- **Backend API**: `http://<YOUR_PUBLIC_IP>:8080`
- **Swagger UI**: `http://<YOUR_PUBLIC_IP>:8080/swagger-ui.html`
- **Health Check**: `http://<YOUR_PUBLIC_IP>:8080/actuator/health`

Example:

- Frontend: `http://54.123.45.67:3000`
- API: `http://54.123.45.67:8080`

## Step 7: Update Application Configuration

### 7.1 Update Base URL in Backend

Edit the application to use your EC2 public IP instead of localhost:

```bash
# Edit docker-compose.yml
nano docker-compose.yml
```

Add environment variable:

```yaml
backend:
  environment:
    APP_BASE_URL: http://<YOUR_PUBLIC_IP>:8080
```

Or update `backend/src/main/java/com/example/urlShortner/service/UrlService.java`:

```java
// Line 30
.shortUrl("http://<YOUR_PUBLIC_IP>:8080/" + url.getShortCode())
```

### 7.2 Rebuild and Restart

```bash
# Rebuild backend
docker-compose up -d --build backend

# Or rebuild all services
docker-compose down
docker-compose up -d --build
```

## Monitoring and Maintenance

### Check Container Status

```bash
docker-compose ps
```

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f mysql
```

### Restart Services

```bash
# Restart all
docker-compose restart

# Restart specific service
docker-compose restart backend
```

### Stop Application

```bash
docker-compose down
```

### Update Application

```bash
# Pull latest changes
git pull origin main

# Rebuild and restart
docker-compose down
docker-compose up -d --build
```

## Database Backup

### Backup MySQL Data

```bash
# Create backup
docker exec urlshortener-mysql mysqldump -u urluser -purlpassword urlshortener > backup_$(date +%Y%m%d).sql

# Download to local machine (from your local terminal)
scp -i url-shortener-key.pem ubuntu@<YOUR_PUBLIC_IP>:~/URL-Shortener/backup_*.sql ./
```

### Restore MySQL Data

```bash
# Upload backup to EC2 (from your local terminal)
scp -i url-shortener-key.pem ./backup.sql ubuntu@<YOUR_PUBLIC_IP>:~/URL-Shortener/

# Restore on EC2
docker exec -i urlshortener-mysql mysql -u urluser -purlpassword urlshortener < backup.sql
```

## Troubleshooting

### Issue: Cannot connect to EC2

**Solution:**

- Check Security Group allows your IP on port 22
- Verify instance is running
- Check you're using correct key file and public IP

### Issue: Containers won't start

**Solution:**

```bash
# Check disk space
df -h

# Check logs
docker-compose logs

# Rebuild from scratch
docker-compose down -v
docker-compose up -d --build
```

### Issue: Application slow/unresponsive

**Solution:**

- t2.micro has limited resources (1GB RAM)
- Check memory usage: `free -h`
- Consider upgrading to t3.small if needed (not free tier)

### Issue: Port already in use

**Solution:**

```bash
# Find process using port
sudo lsof -i :8080

# Kill process
sudo kill -9 <PID>
```

## Security Best Practices

1. **Restrict SSH Access**

   - Edit Security Group to allow SSH only from your IP
   - Don't use `0.0.0.0/0` for SSH

2. **Enable HTTPS** (Production)

   - Get SSL certificate from Let's Encrypt
   - Use Nginx reverse proxy with SSL

3. **Regular Updates**

   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

4. **Change Default Passwords**

   - Update MySQL passwords in docker-compose.yml
   - Don't use default credentials

5. **Enable CloudWatch Monitoring**
   - Set up CloudWatch alarms for CPU/memory usage
   - Monitor disk space

## Cost Optimization

### Free Tier Limits (First 12 Months)

- 750 hours/month of t2.micro (enough for 24/7 operation)
- 30GB EBS storage
- 1GB data transfer out

### To Stay Within Free Tier:

1. Use only 1 t2.micro instance
2. Don't exceed 30GB storage
3. Monitor data transfer (usually fine for development)
4. Stop instance when not needed (saves hours)

### Stop Instance When Not Needed

```bash
# From local machine
aws ec2 stop-instances --instance-ids i-xxxxxxxxxxxxx

# Restart later
aws ec2 start-instances --instance-ids i-xxxxxxxxxxxxx
```

Or use AWS Console: EC2 > Instances > Select instance > Instance State > Stop

## Next Steps

1. ✅ Application deployed on EC2
2. ✅ Update resume: "deployed on AWS EC2"
3. Run performance benchmarks (see `benchmark/README.md`)
4. Set up custom domain (optional)
5. Enable HTTPS with Let's Encrypt (optional)

## Cleanup (When Done)

To avoid charges after free tier expires:

```bash
# On EC2: Stop services
docker-compose down -v

# From local machine or AWS Console:
# Terminate EC2 instance
# Delete Security Group
# Delete Key Pair (optional)
```

## Support

For issues specific to this deployment:

- Check CloudWatch logs
- Review docker-compose logs
- Verify security group rules
- Ensure all services are healthy

---

**Congratulations!** Your URL Shortener is now live on AWS EC2! 🎉

Update your resume to reflect the actual deployment:

> "Deployed on AWS EC2 using Docker containerization with MySQL and Redis"
