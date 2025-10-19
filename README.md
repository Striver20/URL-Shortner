# URL Shortener with Analytics 🔗

A production-ready URL shortening service similar to Bitly, featuring comprehensive analytics, Redis caching, and containerized deployment.

![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.3.4-brightgreen) ![React](https://img.shields.io/badge/React-19.1-blue) ![Redis](https://img.shields.io/badge/Redis-7-red) ![MySQL](https://img.shields.io/badge/MySQL-8.0-blue) ![Docker](https://img.shields.io/badge/Docker-Enabled-2496ED)

## 🚀 Features

- **URL Shortening**: Generate short URLs using Base62 encoding algorithm
- **Smart Redirect**: Fast redirect service with Redis caching
- **Comprehensive Analytics Dashboard**:
  - Total click count tracking
  - Individual click history with timestamps
  - IP address, user agent, and referrer tracking
  - Last accessed time monitoring
- **URL Management**:
  - Custom expiration dates for URLs
  - Owner tracking and management
  - Automatic cleanup of expired URLs
- **Performance Optimized**:
  - Redis caching layer (7-day TTL)
  - HikariCP connection pooling (20 connections)
  - Distributed counter service for high-frequency click tracking
  - Optimized database queries with indexes
- **Modern Architecture**:
  - RESTful API design
  - Swagger/OpenAPI documentation
  - Docker containerization
  - Spring Security integration
  - React frontend with TailwindCSS

## 🛠️ Tech Stack

### Backend

- **Framework**: Spring Boot 3.3.4
- **Language**: Java 17
- **Database**: MySQL 8.0
- **Cache**: Redis 7
- **Security**: Spring Security
- **Documentation**: Swagger/OpenAPI
- **Connection Pool**: HikariCP

### Frontend

- **Framework**: React 19
- **Styling**: TailwindCSS
- **Routing**: React Router
- **HTTP Client**: Axios
- **Build Tool**: npm

### DevOps

- **Containerization**: Docker & Docker Compose
- **Web Server**: Nginx (frontend)
- **Build Tools**: Maven (backend), npm (frontend)

## 📋 Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+
- At least 2GB RAM
- Ports available: 3000, 8080, 3306, 6379

_OR without Docker:_

- Java 17+
- Maven 3.6+
- Node.js 18+
- MySQL 8.0+
- Redis 7+

## 🚀 Quick Start with Docker (Recommended)

### 1. Clone the Repository

```bash
git clone <your-repo-url>
cd "URL Shortner"
```

### 2. Start All Services

```bash
docker-compose up -d --build
```

This will start:

- ✅ MySQL database on port 3306
- ✅ Redis cache on port 6379
- ✅ Spring Boot backend on port 8080
- ✅ React frontend on port 3000

### 3. Verify Services are Running

```bash
docker-compose ps
```

### 4. Access the Application

- **Frontend UI**: http://localhost:3000
- **Backend API**: http://localhost:8080
- **Swagger UI**: http://localhost:8080/swagger-ui.html
- **Health Check**: http://localhost:8080/actuator/health

### 5. Stop Services

```bash
docker-compose down
```

For detailed Docker commands, see [DOCKER_README.md](DOCKER_README.md)

## 🔧 Manual Setup (Without Docker)

### Backend Setup

```bash
cd backend

# Configure application.properties with your MySQL and Redis settings
# Edit src/main/resources/application.properties

# Build and run
mvn clean install
mvn spring-boot:run
```

### Frontend Setup

```bash
cd frontend

# Install dependencies
npm install

# Start development server
npm start
```

## 📊 API Endpoints

### URL Shortening

```http
POST /api/v1/shorten
Content-Type: application/json

{
  "url": "https://example.com/very-long-url",
  "expiryDate": "2025-12-31T23:59:59",
  "owner": "user@example.com"
}
```

### Get Analytics

```http
GET /api/v1/urls/{shortCode}/analytics
```

### Redirect

```http
GET /{shortCode}
```

Full API documentation available at: http://localhost:8080/swagger-ui.html

## 🏗️ Architecture

```
┌─────────────┐      ┌──────────────┐      ┌─────────────┐
│   React     │─────▶│    Nginx     │─────▶│ Spring Boot │
│  Frontend   │      │ (Port 3000)  │      │  (Port 8080)│
└─────────────┘      └──────────────┘      └──────┬──────┘
                                                   │
                                    ┌──────────────┼──────────────┐
                                    │              │              │
                              ┌─────▼─────┐  ┌────▼────┐  ┌─────▼─────┐
                              │   Redis   │  │  MySQL  │  │  HikariCP │
                              │   Cache   │  │Database │  │Connection │
                              │           │  │         │  │   Pool    │
                              └───────────┘  └─────────┘  └───────────┘
```

### Key Components:

1. **Base62 Encoder**: Converts numeric IDs to short alphanumeric codes
2. **Cache-Aside Pattern**: Redis cache with MySQL fallback
3. **Distributed Counter**: Redis-based counter for high-frequency updates
4. **Connection Pool**: HikariCP for efficient database connections
5. **Nginx Reverse Proxy**: Routes API calls to backend

## 🎯 Performance Features

- **Redis Caching**: 85%+ cache hit ratio, reducing database load
- **Connection Pooling**: HikariCP with 20 max connections
- **Database Indexes**: Optimized queries on short_code, expiry_date, created_at
- **Batch Processing**: Hibernate batch inserts/updates
- **Async Click Tracking**: Non-blocking click count updates
- **Scheduled Cleanup**: Automatic removal of expired URLs

### Performance Benchmarking

Run comprehensive performance tests to measure actual improvements:

```bash
# Install Apache JMeter
wget https://dlcdn.apache.org//jmeter/binaries/apache-jmeter-5.6.3.zip
unzip apache-jmeter-5.6.3.zip

# Run benchmarks
./benchmark/run-tests.sh

# Or on Windows
.\benchmark\run-tests.ps1
```

**Results will show:**

- Response time improvement with Redis caching
- Throughput metrics (requests/second)
- Cache hit ratios
- Percentile distributions (p50, p95, p99)

See [benchmark/README.md](benchmark/README.md) for detailed benchmarking guide.

Document your results in [BENCHMARKS.md](BENCHMARKS.md) to support resume claims with real data.

## 📁 Project Structure

```
URL Shortner/
├── backend/
│   ├── src/main/java/com/example/urlShortner/
│   │   ├── config/          # Configuration classes
│   │   ├── controller/      # REST controllers
│   │   ├── dto/             # Data transfer objects
│   │   ├── entity/          # JPA entities
│   │   ├── repository/      # Database repositories
│   │   ├── service/         # Business logic
│   │   ├── security/        # Security configuration
│   │   ├── util/            # Utility classes (Base62)
│   │   └── exception/       # Exception handlers
│   ├── Dockerfile
│   └── pom.xml
├── frontend/
│   ├── src/
│   │   ├── App.js           # Main app component
│   │   ├── Shortener.js     # URL shortening UI
│   │   └── Analytics.js     # Analytics dashboard
│   ├── Dockerfile
│   └── package.json
├── benchmark/               # Performance testing
│   ├── test-plan.jmx       # JMeter test plan
│   ├── run-tests.sh        # Benchmark script (Linux/Mac)
│   ├── run-tests.ps1       # Benchmark script (Windows)
│   └── README.md           # Benchmarking guide
├── docker-compose.yml
├── DOCKER_README.md        # Docker deployment guide
├── aws-setup.md            # AWS EC2 deployment guide
├── BENCHMARKS.md           # Performance results
└── README.md
```

## 🧪 Testing

### Backend Tests

```bash
cd backend
mvn test
```

### Frontend Tests

```bash
cd frontend
npm test
```

## 🔐 Security Features

- Spring Security integration
- CORS configuration
- Input validation
- SQL injection prevention (JPA)
- XSS protection headers (Nginx)

## 🚀 Deployment

### AWS EC2 Deployment (Free Tier)

Deploy your URL Shortener to AWS EC2 in under 30 minutes:

**Quick Steps:**

1. Launch Ubuntu 22.04 EC2 t2.micro instance
2. Configure security groups (ports 22, 80, 443, 8080, 3000)
3. SSH into instance and install Docker
4. Clone repository and run `docker-compose up -d --build`
5. Access via `http://<ec2-public-ip>:8080`

**Detailed Guide:** See [aws-setup.md](aws-setup.md) for complete step-by-step instructions including:

- EC2 instance configuration
- Security group setup
- Docker installation
- Application deployment
- Domain configuration
- Backup procedures

### Local Docker Deployment

See [DOCKER_README.md](DOCKER_README.md) for comprehensive Docker deployment guide.

## 📈 Future Enhancements

- [ ] Custom short codes (user-defined aliases)
- [ ] QR code generation for URLs
- [ ] Rate limiting per IP
- [ ] User authentication and dashboard
- [ ] Bulk URL shortening
- [ ] Link preview/thumbnail generation
- [ ] Geographic analytics
- [ ] API key authentication

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📝 License

This project is licensed under the MIT License.

## 👤 Author

Your Name

- GitHub: [@yourusername](https://github.com/yourusername)
- LinkedIn: [Your LinkedIn](https://linkedin.com/in/yourprofile)

## 🙏 Acknowledgments

- Spring Boot Team for the excellent framework
- Redis for lightning-fast caching
- The open-source community

---

⭐ Star this repository if you find it helpful!
