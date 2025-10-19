#!/bin/bash

# URL Shortener Performance Benchmark Script
# This script runs JMeter performance tests with and without Redis caching

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
JMETER_HOME="${JMETER_HOME:-$HOME/apache-jmeter-5.6.3}"
BASE_URL="${BASE_URL:-localhost:8080}"
NUM_THREADS="${NUM_THREADS:-100}"
LOOP_COUNT="${LOOP_COUNT:-10}"
RESULTS_DIR="./benchmark-results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}URL Shortener Performance Benchmark${NC}"
echo -e "${GREEN}======================================${NC}"
echo ""

# Check if JMeter is installed
if [ ! -d "$JMETER_HOME" ]; then
    echo -e "${RED}Error: JMeter not found at $JMETER_HOME${NC}"
    echo -e "${YELLOW}Please install JMeter or set JMETER_HOME environment variable${NC}"
    echo ""
    echo "To install JMeter:"
    echo "  wget https://dlcdn.apache.org//jmeter/binaries/apache-jmeter-5.6.3.zip"
    echo "  unzip apache-jmeter-5.6.3.zip -d \$HOME"
    exit 1
fi

# Create results directory
mkdir -p "$RESULTS_DIR"

echo -e "${YELLOW}Test Configuration:${NC}"
echo "  Base URL: $BASE_URL"
echo "  Threads: $NUM_THREADS"
echo "  Loop Count: $LOOP_COUNT"
echo "  JMeter Home: $JMETER_HOME"
echo ""

# Function to run JMeter test
run_test() {
    local test_name=$1
    local result_file="$RESULTS_DIR/${test_name}_${TIMESTAMP}.jtl"
    local report_dir="$RESULTS_DIR/${test_name}_${TIMESTAMP}_report"
    
    echo -e "${GREEN}Running test: $test_name${NC}"
    
    # Run JMeter in non-GUI mode
    $JMETER_HOME/bin/jmeter -n \
        -t benchmark/test-plan.jmx \
        -l "$result_file" \
        -e -o "$report_dir" \
        -Jbase_url="$BASE_URL" \
        -Jthreads="$NUM_THREADS" \
        -Jloops="$LOOP_COUNT"
    
    echo -e "${GREEN}Test completed: $test_name${NC}"
    echo -e "Results saved to: $result_file"
    echo -e "HTML Report: $report_dir/index.html"
    echo ""
    
    # Extract key metrics
    extract_metrics "$result_file" "$test_name"
}

# Function to extract metrics from JTL file
extract_metrics() {
    local jtl_file=$1
    local test_name=$2
    local metrics_file="$RESULTS_DIR/${test_name}_${TIMESTAMP}_metrics.txt"
    
    # Calculate statistics using awk
    awk -F',' '
    NR==1 { next }  # Skip header
    {
        elapsed += $2
        latency += $3
        count++
        if ($8 == "true") success++
        if (min == 0 || $2 < min) min = $2
        if ($2 > max) max = $2
    }
    END {
        avg_elapsed = elapsed / count
        avg_latency = latency / count
        success_rate = (success / count) * 100
        
        print "==================================="
        print "Metrics for: '"$test_name"'"
        print "==================================="
        print "Total Requests: " count
        print "Successful: " success " (" success_rate "%)"
        print "Failed: " (count - success)
        print ""
        print "Response Times (ms):"
        print "  Average: " avg_elapsed
        print "  Min: " min
        print "  Max: " max
        print ""
        print "Throughput: " (count / (elapsed / 1000 / count)) " req/sec"
        print "==================================="
    }' "$jtl_file" | tee "$metrics_file"
}

# Check if application is running
echo -e "${YELLOW}Checking if application is running...${NC}"
if ! curl -s "http://$BASE_URL/actuator/health" > /dev/null; then
    echo -e "${RED}Error: Application not responding at http://$BASE_URL${NC}"
    echo -e "${YELLOW}Please start the application first:${NC}"
    echo "  docker-compose up -d"
    exit 1
fi
echo -e "${GREEN}Application is running${NC}"
echo ""

# Step 1: Test WITH Redis Caching (current state)
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Phase 1: Testing WITH Redis Caching${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
run_test "with-redis-cache"

# Step 2: Instructions for testing WITHOUT Redis
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Phase 2: Testing WITHOUT Redis Caching${NC}"
echo -e "${YELLOW}========================================${NC}"
echo ""
echo -e "${YELLOW}To test without Redis caching:${NC}"
echo ""
echo "1. Stop Redis service:"
echo "   docker-compose stop redis"
echo ""
echo "2. Re-run this script to test without caching:"
echo "   ./benchmark/run-tests.sh"
echo ""
echo "3. After testing, restart Redis:"
echo "   docker-compose start redis"
echo ""

# Generate comparison report
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Benchmark Complete${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "Results saved to: ${GREEN}$RESULTS_DIR${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Review HTML reports in $RESULTS_DIR"
echo "2. Compare metrics between with-redis and without-redis tests"
echo "3. Update BENCHMARKS.md with your findings"
echo ""

