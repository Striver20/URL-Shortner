# Performance Benchmarking Guide

This directory contains tools and scripts for running performance benchmarks on the URL Shortener application.

## Quick Start

### Windows (PowerShell)

```powershell
.\benchmark\run-tests.ps1
```

### Linux/Mac (Bash)

```bash
chmod +x benchmark/run-tests.sh
./benchmark/run-tests.sh
```

## Prerequisites

### 1. Install Apache JMeter

**Windows:**

1. Download from [https://jmeter.apache.org/download_jmeter.cgi](https://jmeter.apache.org/download_jmeter.cgi)
2. Extract to `C:\Users\<YourName>\apache-jmeter-5.6.3`
3. Add to PATH or set environment variable

**Linux/Mac:**

```bash
wget https://dlcdn.apache.org//jmeter/binaries/apache-jmeter-5.6.3.zip
unzip apache-jmeter-5.6.3.zip -d $HOME
export JMETER_HOME=$HOME/apache-jmeter-5.6.3
```

### 2. Ensure Application is Running

```bash
# Start all services
docker-compose up -d

# Verify health
curl http://localhost:8080/actuator/health
```

## Running Benchmarks

### Test WITH Redis Caching (Default)

This tests the current optimized setup:

```bash
# Ensure Redis is running
docker-compose start redis

# Run test
./benchmark/run-tests.sh
```

### Test WITHOUT Redis Caching

To establish a baseline for comparison:

```bash
# Stop Redis
docker-compose stop redis

# Run test
./benchmark/run-tests.sh

# Restart Redis after testing
docker-compose start redis
```

## Custom Test Parameters

### Windows (PowerShell)

```powershell
.\benchmark\run-tests.ps1 `
    -BaseUrl "localhost:8080" `
    -NumThreads 200 `
    -LoopCount 20 `
    -JMeterHome "C:\jmeter"
```

### Linux/Mac (Bash)

```bash
export BASE_URL="localhost:8080"
export NUM_THREADS=200
export LOOP_COUNT=20
export JMETER_HOME="/path/to/jmeter"
./benchmark/run-tests.sh
```

## Test Configuration

### Default Settings

- **Concurrent Users**: 100 threads
- **Loops per User**: 10
- **Ramp-up Time**: 10 seconds
- **Total Requests**: ~1,000 (100 users × 10 loops)
- **Request Mix**:
  - 70% URL Redirects
  - 30% Analytics Queries

### Load Scenarios

#### Light Load (Development)

```bash
NUM_THREADS=10 LOOP_COUNT=5 ./benchmark/run-tests.sh
```

#### Medium Load (Testing)

```bash
NUM_THREADS=100 LOOP_COUNT=10 ./benchmark/run-tests.sh
```

#### Heavy Load (Stress Test)

```bash
NUM_THREADS=500 LOOP_COUNT=20 ./benchmark/run-tests.sh
```

## Understanding Results

### Output Files

Results are saved in `benchmark-results/`:

1. **JTL File**: Raw test results

   - `with-redis-cache_[timestamp].jtl`
   - CSV format with all request details

2. **HTML Report**: Visual dashboard

   - `with-redis-cache_[timestamp]_report/index.html`
   - Charts, graphs, and statistics
   - Open in browser for analysis

3. **Metrics File**: Summary statistics
   - `with-redis-cache_[timestamp]_metrics.txt`
   - Key performance indicators

### Key Metrics Explained

**Response Time (ms)**

- Average: Mean time across all requests
- Median: 50th percentile (middle value)
- 90th Percentile: 90% of requests faster than this
- 95th Percentile: 95% of requests faster than this
- 99th Percentile: 99% of requests faster than this

**Throughput (req/sec)**

- Number of requests processed per second
- Higher is better

**Success Rate (%)**

- Percentage of successful requests (HTTP 200-399)
- Should be close to 100%

**Error Rate (%)**

- Percentage of failed requests
- Lower is better

## Comparing Results

### Calculate Improvement

```
Improvement % = ((Baseline - Optimized) / Baseline) × 100

Example:
Baseline (no Redis): 150ms average
Optimized (with Redis): 60ms average
Improvement = ((150 - 60) / 150) × 100 = 60%
```

### Visual Comparison

Open HTML reports side-by-side:

- `benchmark-results/without-redis-cache_*/index.html`
- `benchmark-results/with-redis-cache_*/index.html`

Compare:

- Response Time Over Time graph
- Transactions per Second chart
- Response Time Percentiles

## Testing on AWS EC2

### Remote Testing

From your local machine to EC2:

```bash
# Set EC2 public IP
export BASE_URL="54.123.45.67:8080"

# Run test
./benchmark/run-tests.sh
```

### On EC2 Instance

```bash
# SSH into EC2
ssh -i key.pem ubuntu@<ec2-ip>

# Install JMeter
wget https://dlcdn.apache.org//jmeter/binaries/apache-jmeter-5.6.3.zip
unzip apache-jmeter-5.6.3.zip

# Run test
export JMETER_HOME=$HOME/apache-jmeter-5.6.3
cd URL-Shortener
./benchmark/run-tests.sh
```

## Troubleshooting

### JMeter Not Found

**Error**: `JMeter not found at...`

**Solution**:

```bash
# Set JMETER_HOME
export JMETER_HOME=/path/to/jmeter

# Or specify in command
JMETER_HOME=/path/to/jmeter ./benchmark/run-tests.sh
```

### Application Not Running

**Error**: `Application not responding`

**Solution**:

```bash
# Start application
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs backend
```

### Out of Memory

**Error**: JMeter runs out of memory

**Solution**: Increase JMeter heap size

```bash
# Edit jmeter (Linux/Mac)
export HEAP="-Xms1g -Xmx2g"

# Edit jmeter.bat (Windows)
set HEAP=-Xms1g -Xmx2g
```

### Connection Refused

**Error**: Connection refused during test

**Solution**:

- Check firewall/security groups allow port 8080
- Verify application is accepting connections
- Reduce thread count if server is overloaded

## Advanced Usage

### Running Specific Test Plan

```bash
jmeter -n \
  -t benchmark/test-plan.jmx \
  -l results.jtl \
  -e -o report/ \
  -Jbase_url=localhost:8080 \
  -Jthreads=100 \
  -Jloops=10
```

### Distributed Testing

For higher load:

```bash
# Start JMeter servers on multiple machines
jmeter-server

# Run from controller
jmeter -n -t test-plan.jmx \
  -R server1,server2,server3 \
  -l results.jtl
```

### Custom Assertions

Edit `test-plan.jmx` in JMeter GUI:

1. Open JMeter GUI: `jmeter`
2. Open `benchmark/test-plan.jmx`
3. Add assertions, listeners, or samplers
4. Save and re-run tests

## Best Practices

1. **Warm-up Period**

   - Run once to warm up caches
   - Discard first run results
   - Use second run for metrics

2. **Consistent Environment**

   - Test at same time of day
   - Same network conditions
   - No other processes running

3. **Multiple Runs**

   - Run tests 3-5 times
   - Average the results
   - Report standard deviation

4. **Monitor Resources**

   ```bash
   # Watch system resources during test
   docker stats

   # Monitor logs
   docker-compose logs -f backend
   ```

5. **Realistic Scenarios**
   - Mix read/write operations
   - Vary URL patterns
   - Include error scenarios

## Integration with CI/CD

### GitHub Actions Example

```yaml
name: Performance Test

on: [push]

jobs:
  benchmark:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Start application
        run: docker-compose up -d

      - name: Install JMeter
        run: |
          wget https://dlcdn.apache.org//jmeter/binaries/apache-jmeter-5.6.3.zip
          unzip apache-jmeter-5.6.3.zip

      - name: Run benchmarks
        run: |
          export JMETER_HOME=$PWD/apache-jmeter-5.6.3
          ./benchmark/run-tests.sh

      - name: Upload results
        uses: actions/upload-artifact@v2
        with:
          name: benchmark-results
          path: benchmark-results/
```

## Resources

- [JMeter Best Practices](https://jmeter.apache.org/usermanual/best-practices.html)
- [Load Testing Guide](https://www.blazemeter.com/blog/jmeter-load-testing)
- [Performance Testing](https://martinfowler.com/articles/practical-test-pyramid.html#PerformanceTests)

---

**Questions?** Check main documentation in `BENCHMARKS.md` or open an issue.
