# URL Shortener Performance Benchmark Script (PowerShell)
# This script runs JMeter performance tests with and without Redis caching

param(
    [string]$BaseUrl = "localhost:8080",
    [int]$NumThreads = 100,
    [int]$LoopCount = 10,
    [string]$JMeterHome = "$env:USERPROFILE\apache-jmeter-5.6.3"
)

$ErrorActionPreference = "Stop"

# Configuration
$ResultsDir = ".\benchmark-results"
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

Write-Host "======================================" -ForegroundColor Green
Write-Host "URL Shortener Performance Benchmark" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""

# Check if JMeter is installed
if (-not (Test-Path "$JMeterHome\bin\jmeter.bat")) {
    Write-Host "Error: JMeter not found at $JMeterHome" -ForegroundColor Red
    Write-Host "Please install JMeter or set JMeterHome parameter" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To install JMeter:"
    Write-Host "  1. Download from https://jmeter.apache.org/download_jmeter.cgi"
    Write-Host "  2. Extract to $env:USERPROFILE\apache-jmeter-5.6.3"
    Write-Host ""
    Write-Host "Or specify custom location:"
    Write-Host '  .\run-tests.ps1 -JMeterHome "C:\path\to\jmeter"'
    exit 1
}

# Create results directory
New-Item -ItemType Directory -Force -Path $ResultsDir | Out-Null

Write-Host "Test Configuration:" -ForegroundColor Yellow
Write-Host "  Base URL: $BaseUrl"
Write-Host "  Threads: $NumThreads"
Write-Host "  Loop Count: $LoopCount"
Write-Host "  JMeter Home: $JMeterHome"
Write-Host ""

# Function to run JMeter test
function Run-Test {
    param(
        [string]$TestName
    )
    
    $ResultFile = "$ResultsDir\${TestName}_${Timestamp}.jtl"
    $ReportDir = "$ResultsDir\${TestName}_${Timestamp}_report"
    
    Write-Host "Running test: $TestName" -ForegroundColor Green
    
    # Run JMeter in non-GUI mode
    & "$JMeterHome\bin\jmeter.bat" -n `
        -t "benchmark\test-plan.jmx" `
        -l "$ResultFile" `
        -e -o "$ReportDir" `
        -Jbase_url="$BaseUrl" `
        -Jthreads="$NumThreads" `
        -Jloops="$LoopCount"
    
    Write-Host "Test completed: $TestName" -ForegroundColor Green
    Write-Host "Results saved to: $ResultFile"
    Write-Host "HTML Report: $ReportDir\index.html"
    Write-Host ""
    
    # Extract key metrics
    Extract-Metrics -JtlFile $ResultFile -TestName $TestName
}

# Function to extract metrics from JTL file
function Extract-Metrics {
    param(
        [string]$JtlFile,
        [string]$TestName
    )
    
    $MetricsFile = "$ResultsDir\${TestName}_${Timestamp}_metrics.txt"
    
    # Read CSV and calculate stats
    $data = Import-Csv $JtlFile
    
    $totalRequests = $data.Count
    $successful = ($data | Where-Object { $_.success -eq "true" }).Count
    $failed = $totalRequests - $successful
    $successRate = ($successful / $totalRequests) * 100
    
    $elapsedTimes = $data | ForEach-Object { [int]$_.elapsed }
    $avgElapsed = ($elapsedTimes | Measure-Object -Average).Average
    $minElapsed = ($elapsedTimes | Measure-Object -Minimum).Minimum
    $maxElapsed = ($elapsedTimes | Measure-Object -Maximum).Maximum
    
    $throughput = $totalRequests / (($elapsedTimes | Measure-Object -Average).Average / 1000)
    
    $metrics = @"
===================================
Metrics for: $TestName
===================================
Total Requests: $totalRequests
Successful: $successful ($([math]::Round($successRate, 2))%)
Failed: $failed

Response Times (ms):
  Average: $([math]::Round($avgElapsed, 2))
  Min: $minElapsed
  Max: $maxElapsed

Throughput: $([math]::Round($throughput, 2)) req/sec
===================================
"@
    
    Write-Host $metrics
    $metrics | Out-File -FilePath $MetricsFile
}

# Check if application is running
Write-Host "Checking if application is running..." -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "http://$BaseUrl/actuator/health" -TimeoutSec 5
    Write-Host "Application is running (Status: $($health.status))" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "Error: Application not responding at http://$BaseUrl" -ForegroundColor Red
    Write-Host "Please start the application first:" -ForegroundColor Yellow
    Write-Host "  docker-compose up -d"
    exit 1
}

# Step 1: Test WITH Redis Caching (current state)
Write-Host "========================================" -ForegroundColor Green
Write-Host "Phase 1: Testing WITH Redis Caching" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Run-Test -TestName "with-redis-cache"

# Step 2: Instructions for testing WITHOUT Redis
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "Phase 2: Testing WITHOUT Redis Caching" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "To test without Redis caching:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Stop Redis service:"
Write-Host "   docker-compose stop redis"
Write-Host ""
Write-Host "2. Re-run this script to test without caching:"
Write-Host "   .\benchmark\run-tests.ps1"
Write-Host ""
Write-Host "3. After testing, restart Redis:"
Write-Host "   docker-compose start redis"
Write-Host ""

# Generate comparison report
Write-Host "========================================" -ForegroundColor Green
Write-Host "Benchmark Complete" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Results saved to: $ResultsDir" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Review HTML reports in $ResultsDir"
Write-Host "2. Compare metrics between with-redis and without-redis tests"
Write-Host "3. Update BENCHMARKS.md with your findings"
Write-Host ""

