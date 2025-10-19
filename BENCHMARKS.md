# Performance Benchmark Results - URL Shortener

## Executive Summary

This document presents comprehensive performance benchmark results for the URL Shortener application, comparing response times with and without Redis caching.

**Key Findings:**

- Average response time improvement: **[TO BE FILLED]%**
- Cache hit ratio: **[TO BE FILLED]%**
- Throughput increase: **[TO BE FILLED] requests/second**

---

## Test Environment

### Hardware Specifications

- **Platform**: AWS EC2 t2.micro (or Local Development)
- **vCPUs**: 1
- **RAM**: 1 GB
- **Storage**: 30 GB SSD
- **Network**: AWS Free Tier bandwidth

### Software Stack

- **Operating System**: Ubuntu 22.04 LTS
- **Java Runtime**: OpenJDK 17 (Eclipse Temurin)
- **Spring Boot**: 3.3.4
- **MySQL**: 8.0
- **Redis**: 7-alpine
- **Docker**: 24.x
- **Docker Compose**: 2.x

### Test Configuration

- **Testing Tool**: Apache JMeter 5.6.3
- **Test Duration**: 10 loops per thread
- **Concurrent Users**: 100 threads
- **Ramp-up Time**: 10 seconds
- **Request Mix**:
  - 70% URL Redirects (GET /{shortCode})
  - 30% Analytics Requests (GET /api/v1/urls/{shortCode}/analytics)

---

## Baseline Test (WITHOUT Redis Caching)

### Test Setup

- Redis service stopped: `docker-compose stop redis`
- All requests hit MySQL database directly
- No caching layer active

### Results

| Metric                    | Value                  |
| ------------------------- | ---------------------- |
| **Total Requests**        | [TO BE FILLED]         |
| **Successful Requests**   | [TO BE FILLED]         |
| **Failed Requests**       | [TO BE FILLED]         |
| **Success Rate**          | [TO BE FILLED]%        |
| **Average Response Time** | [TO BE FILLED] ms      |
| **Median Response Time**  | [TO BE FILLED] ms      |
| **90th Percentile**       | [TO BE FILLED] ms      |
| **95th Percentile**       | [TO BE FILLED] ms      |
| **99th Percentile**       | [TO BE FILLED] ms      |
| **Min Response Time**     | [TO BE FILLED] ms      |
| **Max Response Time**     | [TO BE FILLED] ms      |
| **Throughput**            | [TO BE FILLED] req/sec |
| **Error Rate**            | [TO BE FILLED]%        |

### Observations

- [ ] High database load observed
- [ ] Response times vary significantly
- [ ] No cache hits (expected)

---

## Optimized Test (WITH Redis Caching)

### Test Setup

- Redis service running: `docker-compose start redis`
- Cache TTL: 7 days (10,080 minutes)
- Frequently accessed URLs cached

### Results

| Metric                    | Value                  |
| ------------------------- | ---------------------- |
| **Total Requests**        | [TO BE FILLED]         |
| **Successful Requests**   | [TO BE FILLED]         |
| **Failed Requests**       | [TO BE FILLED]         |
| **Success Rate**          | [TO BE FILLED]%        |
| **Average Response Time** | [TO BE FILLED] ms      |
| **Median Response Time**  | [TO BE FILLED] ms      |
| **90th Percentile**       | [TO BE FILLED] ms      |
| **95th Percentile**       | [TO BE FILLED] ms      |
| **99th Percentile**       | [TO BE FILLED] ms      |
| **Min Response Time**     | [TO BE FILLED] ms      |
| **Max Response Time**     | [TO BE FILLED] ms      |
| **Throughput**            | [TO BE FILLED] req/sec |
| **Error Rate**            | [TO BE FILLED]%        |
| **Cache Hit Ratio**       | [TO BE FILLED]%        |

### Observations

- [ ] Reduced database queries
- [ ] Consistent response times
- [ ] Higher throughput achieved

---

## Performance Comparison

### Response Time Improvement

| Metric              | Without Redis | With Redis | Improvement |
| ------------------- | ------------- | ---------- | ----------- |
| **Average**         | [X] ms        | [Y] ms     | **[Z]%**    |
| **Median**          | [X] ms        | [Y] ms     | **[Z]%**    |
| **95th Percentile** | [X] ms        | [Y] ms     | **[Z]%**    |
| **Max**             | [X] ms        | [Y] ms     | **[Z]%**    |

**Formula**: `Improvement % = ((Without - With) / Without) * 100`

### Throughput Improvement

| Metric           | Without Redis | With Redis | Improvement |
| ---------------- | ------------- | ---------- | ----------- |
| **Requests/sec** | [X]           | [Y]        | **[Z]%**    |

### Visual Comparison

```
Average Response Time Comparison:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Without Redis: [████████████████████] [X] ms
With Redis:    [████] [Y] ms
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Improvement: [Z]%
```

---

## Analysis

### Why Redis Caching Improves Performance

1. **Reduced Database Load**

   - Cache hits avoid expensive database queries
   - MySQL connection pool remains available for writes
   - Reduced lock contention on database tables

2. **In-Memory Data Access**

   - Redis stores data in RAM (vs. disk for MySQL)
   - Faster data retrieval (sub-millisecond)
   - No SQL parsing or query optimization overhead

3. **Connection Efficiency**
   - Persistent Redis connections
   - Fewer MySQL connections needed
   - HikariCP pool optimized for write operations

### Cache Hit Patterns

Based on test results:

- **First request**: Cache miss → Database query → Cache population
- **Subsequent requests**: Cache hit → Instant response
- **Expired entries**: Automatic eviction after TTL (7 days)

### Optimization Techniques Used

1. **HikariCP Connection Pooling**

   - Maximum pool size: 20 connections
   - Minimum idle: 5 connections
   - Connection timeout: 20 seconds

2. **Redis Configuration**

   - Max memory: 256MB
   - Eviction policy: allkeys-lru (Least Recently Used)
   - Persistence: Append-only file (AOF)

3. **Database Indexing**
   - Index on `short_code` column (unique)
   - Index on `expiry_date` for cleanup queries

---

## Recommendations for Further Optimization

### 1. Database Level

- [ ] Add read replicas for MySQL (if scaling beyond free tier)
- [ ] Implement database query result caching
- [ ] Optimize slow queries identified in logs

### 2. Application Level

- [ ] Implement asynchronous click tracking
- [ ] Use Redis Pub/Sub for counter synchronization
- [ ] Add circuit breaker pattern for database failures

### 3. Infrastructure Level

- [ ] Enable CDN for static content
- [ ] Use AWS ElastiCache for Redis (managed service)
- [ ] Implement load balancing for horizontal scaling

### 4. Monitoring

- [ ] Set up CloudWatch metrics
- [ ] Monitor cache hit ratios in real-time
- [ ] Alert on high error rates or slow queries

---

## Reproducing These Results

### Prerequisites

1. AWS EC2 instance running (or local Docker setup)
2. Apache JMeter installed
3. Application deployed and healthy

### Steps

```bash
# 1. Clone repository
git clone <your-repo-url>
cd URL-Shortener

# 2. Ensure application is running
docker-compose up -d

# 3. Run baseline test (without Redis)
docker-compose stop redis
./benchmark/run-tests.sh

# 4. Run optimized test (with Redis)
docker-compose start redis
./benchmark/run-tests.sh

# 5. Compare results in benchmark-results/ directory
```

### For Windows Users

```powershell
.\benchmark\run-tests.ps1
```

---

## Conclusions

### Performance Impact

The implementation of Redis caching resulted in a **[TO BE FILLED]%** improvement in average response time. This significant enhancement demonstrates the value of:

- In-memory caching for frequently accessed data
- Proper connection pool management
- Strategic use of TTL-based cache invalidation

### Resume-Ready Metrics

Based on these benchmarks, the following claims can be made:

> "Optimized URL Shortener performance by **[X]%** through Redis caching implementation and HikariCP connection pooling (20 max connections)"

> "Achieved **[Y]** requests/second throughput on AWS EC2 t2.micro instance under 100 concurrent users"

> "Reduced database load by **[Z]%** via strategic caching layer with 7-day TTL"

### Real-World Application

In production with higher load:

- Estimated 80-90% cache hit ratio for popular URLs
- Database reserved for writes and cache misses
- Scalable architecture supporting thousands of requests/second

---

## Test Artifacts

- **JMeter Test Plan**: `benchmark/test-plan.jmx`
- **Baseline Results**: `benchmark-results/without-redis-cache_[timestamp].jtl`
- **Optimized Results**: `benchmark-results/with-redis-cache_[timestamp].jtl`
- **HTML Reports**: `benchmark-results/*/index.html`

---

## Version History

| Date   | Tester | Environment      | Notes             |
| ------ | ------ | ---------------- | ----------------- |
| [DATE] | [NAME] | AWS EC2 t2.micro | Initial benchmark |
| [DATE] | [NAME] | Local Docker     | Validation test   |

---

## References

- [Apache JMeter Documentation](https://jmeter.apache.org/usermanual/index.html)
- [Redis Best Practices](https://redis.io/docs/manual/patterns/)
- [HikariCP Configuration](https://github.com/brettwooldridge/HikariCP#configuration-knobs-baby)
- [Spring Boot Caching Guide](https://spring.io/guides/gs/caching/)

---

**Last Updated**: [DATE]  
**Test Engineer**: [YOUR NAME]  
**Version**: 1.0
