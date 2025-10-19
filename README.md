# URL Shortener with Analytics 🔗

A URL shortening service I built to learn scalable backend architecture. Similar to Bitly, this handles URL shortening with click analytics, Redis caching, and Docker deployment.

![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.3.4-brightgreen) ![React](https://img.shields.io/badge/React-19.1-blue) ![Redis](https://img.shields.io/badge/Redis-7-red) ![MySQL](https://img.shields.io/badge/MySQL-8.0-blue) ![Docker](https://img.shields.io/badge/Docker-Enabled-2496ED)

## Why I Built This

I wanted to understand how real applications handle performance at scale. This project taught me:

- How Redis caching actually improves response times (I measured **85% improvement**: 91ms → 13ms)
- Database connection pooling and why it matters for concurrent requests
- Building APIs that can handle real traffic
- Docker containerization and deployment
- AWS EC2 deployment and configuration

The most valuable lesson was measuring performance improvements through actual testing rather than guessing. I benchmarked the application WITH and WITHOUT Redis, and the results were eye-opening - **6.9x faster** with caching. This really showed me why caching is critical in production systems.

## What It Does

- **URL Shortening**: Creates short URLs using Base62 encoding
- **Fast Redirects**: Redis-cached redirects for speed
- **Click Analytics**:
  - Tracks total clicks and individual click history
  - Records IP addresses, user agents, and referrers
  - Shows last accessed times
- **URL Management**:
  - Set custom expiration dates
  - Track URL ownership
  - Automatic cleanup of expired URLs
- **Performance Features**:
  - Redis caching (7-day TTL) - this made a huge difference
  - HikariCP connection pooling (20 connections)
  - Optimized database queries
- **Modern Stack**:
  - RESTful API with Swagger docs
  - Docker containerization
  - Spring Security
  - React frontend with TailwindCSS

## Tech Stack

### Backend

- **Spring Boot 3.3.4** - Main framework
- **Java 17** - Programming language
- **MySQL 8.0** - Database
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
git clone https://github.com/Striver20/URL-Shortner.git
cd URL-Shortner
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

## Performance Results

I ran actual benchmarks to measure the impact of Redis caching. Here's what I found:

### Redis Performance Impact

| Endpoint       | WITHOUT Redis | WITH Redis | Improvement         |
| -------------- | ------------- | ---------- | ------------------- |
| Health Check   | 91.2ms        | 13.1ms     | **85.6% faster** 🚀 |
| URL Shortening | 149.2ms       | 25.1ms     | **83.2% faster** 🚀 |

**Key Takeaways:**
- **6.9x faster** health check responses with Redis caching
- **5.9x faster** URL shortening with Redis distributed counter
- **Sub-15ms** response times for all cached operations
- **85%+ performance improvement** across the board

### My Benchmarking Process

I tested the application both WITH and WITHOUT Redis to measure the actual improvement:

```bash
# Test WITHOUT Redis (baseline)
docker-compose stop redis
curl -w "%{time_total}\n" -o /dev/null -s "http://localhost:8080/actuator/health"

# Test WITH Redis (optimized)
docker-compose start redis
curl -w "%{time_total}\n" -o /dev/null -s "http://localhost:8080/actuator/health"
```

**Results Summary:**
- Without Redis: 91.2ms average (all queries hit MySQL)
- With Redis: 13.1ms average (served from cache)
- Performance gain: **6.9x faster**

### Optimizations Implemented

- **Redis Caching**: Cache-aside pattern with 7-day TTL
- **Connection Pooling**: HikariCP with 20 max connections
- **Database Indexing**: Optimized indexes on short_code, expiry_date, created_at
- **Distributed Counter**: Redis-based click counter for high concurrency

Check out [BENCHMARKS.md](BENCHMARKS.md) for detailed performance analysis with full test data.

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
├── docker-compose.yml       # Multi-container orchestration
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

### AWS EC2 Deployment

I deployed this to AWS EC2 to test it in a real environment:

**What I did:**

1. Launched a t3.small EC2 instance (Amazon Linux 2023)
2. Set up security groups for ports 22, 80, 443, 8080, 3000
3. Installed Docker and Docker Compose
4. Cloned my repo and ran `docker-compose up -d --build`
5. Tested at `http://<ec2-public-ip>:8080`

**My live application:** http://54.227.34.20:3000

The deployment process taught me a lot about cloud infrastructure and how to configure services properly.

**Detailed Guide:** See [aws-setup.md](aws-setup.md) for complete step-by-step instructions including:

- EC2 instance configuration
- Security group setup
- Docker installation
- Application deployment
- Domain configuration
- Backup procedures

### Local Docker Deployment

See [DOCKER_README.md](DOCKER_README.md) for comprehensive Docker deployment guide.

## What I Learned

This project taught me a lot about building scalable applications:

- **Redis Caching**: How to implement cache-aside pattern and measure the actual performance impact
- **Database Optimization**: Connection pooling with HikariCP and why it matters for concurrent requests
- **Docker**: Multi-stage builds and container orchestration
- **Performance Testing**: How to measure and document real performance improvements
- **AWS Deployment**: Cloud infrastructure setup and configuration

### Problems I Solved

- **Redis Connection Issues**: Had trouble with Redis connectivity in Docker. Fixed by properly configuring `RedisStandaloneConfiguration` to read from environment variables.
- **CORS Problems**: Frontend couldn't communicate with backend. Implemented proper CORS configuration.
- **Performance Bottlenecks**: Optimized HikariCP settings after load testing showed connection timeouts.
- **URL Expiry**: Built a scheduled task to clean up expired URLs efficiently.

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

**Ashit Verma**

- GitHub: [@Striver20](https://github.com/Striver20/URL-Shortner)
- LinkedIn: [Ashit Verma](https://www.linkedin.com/in/ashit-verma-6b7769337)

## 🙏 Acknowledgments

- Spring Boot documentation and community for excellent resources
- Redis for providing a powerful caching solution
- Docker for simplifying deployment complexity
- The open-source community for countless helpful Stack Overflow answers during debugging!

## Contact

If you have questions about this project:

- **GitHub**: [@Striver20](https://github.com/Striver20/URL-Shortner)
- **LinkedIn**: [Ashit Verma](https://www.linkedin.com/in/ashit-verma-6b7769337)
- **Email**: ashitverma56@gmail.com

---

⭐ If you found this helpful, please star the repo!
