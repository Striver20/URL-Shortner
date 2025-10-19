# AWS Deployment & Benchmarking Checklist

This checklist helps you complete the AWS EC2 deployment and performance benchmarking to support your resume claims.

## Current Status

### ✅ Completed (Automated)

- [x] Redis caching implementation in UrlService
- [x] HikariCP connection pooling configured (20 max connections)
- [x] JMeter test plan created (`benchmark/test-plan.jmx`)
- [x] Benchmark automation scripts (Bash & PowerShell)
- [x] AWS EC2 deployment guide (`aws-setup.md`)
- [x] Benchmark documentation template (`BENCHMARKS.md`)
- [x] Updated README with deployment and benchmarking sections

### ⏳ To Be Completed (Manual Steps)

## Phase 1: AWS EC2 Deployment

**Estimated Time: 30-45 minutes**

- [ ] **Step 1**: Launch EC2 Instance

  - [ ] Log in to AWS Console
  - [ ] Launch t2.micro Ubuntu 22.04 instance
  - [ ] Create and download key pair (`url-shortener-key.pem`)
  - [ ] Configure security groups (ports 22, 80, 443, 8080, 3000)
  - [ ] Note public IP address: `_______________`

- [ ] **Step 2**: Connect to EC2

  - [ ] SSH into instance: `ssh -i key.pem ubuntu@<IP>`
  - [ ] Verify connection successful

- [ ] **Step 3**: Install Dependencies

  - [ ] Run: `sudo apt update && sudo apt upgrade -y`
  - [ ] Install Docker: `sudo apt install docker.io -y`
  - [ ] Install Docker Compose: `sudo apt install docker-compose -y`
  - [ ] Add user to docker group: `sudo usermod -aG docker ubuntu`
  - [ ] Verify: `docker --version` and `docker-compose --version`

- [ ] **Step 4**: Deploy Application

  - [ ] Push code to GitHub (if not already done)
  - [ ] Clone repo: `git clone <your-repo-url>`
  - [ ] Navigate: `cd URL-Shortener`
  - [ ] Deploy: `docker-compose up -d --build`
  - [ ] Wait 5-10 minutes for build

- [ ] **Step 5**: Verify Deployment
  - [ ] Check containers: `docker-compose ps` (all should be "Up")
  - [ ] Test health: `curl http://localhost:8080/actuator/health`
  - [ ] Access from browser: `http://<EC2-IP>:8080`
  - [ ] Test frontend: `http://<EC2-IP>:3000`

**Detailed Instructions**: See `aws-setup.md`

---

## Phase 2: Performance Benchmarking

**Estimated Time: 2-3 hours**

### Prerequisites

- [ ] Application running on EC2 or locally
- [ ] Apache JMeter installed

### Installation

**Windows:**

```powershell
# Download from https://jmeter.apache.org/download_jmeter.cgi
# Extract to C:\Users\<YourName>\apache-jmeter-5.6.3
```

**Linux/Mac:**

```bash
wget https://dlcdn.apache.org//jmeter/binaries/apache-jmeter-5.6.3.zip
unzip apache-jmeter-5.6.3.zip -d $HOME
export JMETER_HOME=$HOME/apache-jmeter-5.6.3
```

### Run Benchmarks

- [ ] **Test 1: WITH Redis Caching**

  - [ ] Ensure Redis is running: `docker-compose ps redis`
  - [ ] Run test: `./benchmark/run-tests.sh` (or `.ps1` on Windows)
  - [ ] Wait for completion (~10-15 minutes)
  - [ ] Note average response time: `_____ ms`
  - [ ] Note throughput: `_____ req/sec`

- [ ] **Test 2: WITHOUT Redis Caching**

  - [ ] Stop Redis: `docker-compose stop redis`
  - [ ] Run test again: `./benchmark/run-tests.sh`
  - [ ] Wait for completion (~10-15 minutes)
  - [ ] Note average response time: `_____ ms`
  - [ ] Note throughput: `_____ req/sec`
  - [ ] Restart Redis: `docker-compose start redis`

- [ ] **Calculate Improvement**

  ```
  Improvement % = ((Without - With) / Without) × 100

  Example:
  Without Redis: 150ms
  With Redis: 60ms
  Improvement = ((150 - 60) / 150) × 100 = 60%

  Your calculation:
  Without Redis: _____ ms
  With Redis: _____ ms
  Improvement = _____ %
  ```

**Detailed Instructions**: See `benchmark/README.md`

---

## Phase 3: Documentation

**Estimated Time: 30 minutes**

- [ ] **Update BENCHMARKS.md**

  - [ ] Fill in all "[TO BE FILLED]" placeholders
  - [ ] Add actual test results
  - [ ] Calculate and document improvement percentage
  - [ ] Add date and your name

- [ ] **Update Resume**

Current (unverified claim):

```
"Reduced average response time by 60% via connection pooling and optimized query design"
```

Update to (based on your actual results):

```
"Optimized URL Shortener performance by X% through Redis caching and HikariCP
connection pooling, handling Y requests/second on AWS EC2 t2.micro"
```

Replace X and Y with your actual benchmark numbers!

- [ ] **Screenshot Evidence**
  - [ ] Take screenshot of EC2 instance running
  - [ ] Take screenshot of application working (frontend)
  - [ ] Take screenshot of JMeter results
  - [ ] Save in `evidence/` folder for interview prep

---

## Phase 4: Resume Updates

### ❌ Remove These Claims

- [ ] ~~"for high availability"~~ (single instance = not HA)
- [ ] ~~Any unverified percentage claims~~

### ✅ Add These (With Actual Data)

Update your resume with:

```
URL Shortener with Analytics | Spring Boot, Redis, Docker, MySQL
• Built a full-stack URL shortening service with real-time click analytics
  tracking IP addresses, user agents, and referrers
• Optimized performance by [YOUR_PERCENTAGE]% through Redis caching layer and
  HikariCP connection pooling (20 max connections)
• Deployed on AWS EC2 using Docker containerization with MySQL and Redis,
  handling [YOUR_THROUGHPUT] requests/second under load testing
• Implemented comprehensive analytics dashboard with React and TailwindCSS
```

---

## Verification Checklist

Before updating your resume, verify you can answer these interview questions:

- [ ] "Show me the live deployment" → `http://<your-ec2-ip>:8080`
- [ ] "How did you measure the X% improvement?" → Show BENCHMARKS.md
- [ ] "What caching strategy did you use?" → Cache-aside pattern with 7-day TTL
- [ ] "Why Redis?" → In-memory speed, TTL support, simple key-value operations
- [ ] "How does HikariCP help?" → Reuses connections, reduces overhead, 20 max pool size
- [ ] "What's your deployment process?" → Docker Compose, multi-stage builds
- [ ] "Show me the architecture" → Explain diagram in README

---

## Time Investment Summary

| Phase                    | Estimated Time | Complexity    |
| ------------------------ | -------------- | ------------- |
| AWS EC2 Setup            | 30-45 min      | Easy          |
| Performance Benchmarking | 2-3 hours      | Medium        |
| Documentation            | 30 min         | Easy          |
| **Total**                | **~4 hours**   | **Worth it!** |

---

## Support Resources

- **AWS Setup Issues**: See `aws-setup.md` troubleshooting section
- **Benchmark Issues**: See `benchmark/README.md` troubleshooting
- **Docker Issues**: See `DOCKER_README.md`
- **Application Issues**: Check `docker-compose logs`

---

## After Completion

### You Will Have:

1. ✅ Live application on AWS EC2 (free tier)
2. ✅ Documented performance improvements with real data
3. ✅ Honest, verifiable resume claims
4. ✅ Evidence to show in interviews

### Cost: $0/month (within free tier)

### Resume Impact: HUGE

Interviewers love candidates who can:

- Show live deployments
- Back up claims with data
- Explain architectural decisions
- Demonstrate cloud experience

---

## Quick Reference

**Your EC2 Public IP**: `_______________`

**Application URLs**:

- Frontend: `http://<IP>:3000`
- Backend: `http://<IP>:8080`
- Swagger: `http://<IP>:8080/swagger-ui.html`

**Your Benchmark Results**:

- With Redis: `_____ms average`
- Without Redis: `_____ms average`
- Improvement: `_____%`
- Throughput: `_____ req/sec`

---

**Ready to start?** Begin with Phase 1: AWS EC2 Deployment!

Follow `aws-setup.md` for detailed step-by-step instructions.
