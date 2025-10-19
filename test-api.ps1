# URL Shortener - Comprehensive API Test Script
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  URL Shortener - API Test Suite" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Backend Health Check
Write-Host "[TEST 1] Backend Health Check..." -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "http://localhost:8080/actuator/health" -Method GET
    Write-Host "Success - Backend is healthy: $($health.status)" -ForegroundColor Green
}
catch {
    Write-Host "Failed - Backend health check failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 2: Frontend Accessibility
Write-Host "`n[TEST 2] Frontend Accessibility..." -ForegroundColor Yellow
try {
    $frontend = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing -TimeoutSec 5
    Write-Host "Success - Frontend accessible (Status: $($frontend.StatusCode))" -ForegroundColor Green
}
catch {
    Write-Host "Warning - Frontend not accessible: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Create Short URL
Write-Host "`n[TEST 3] Create Short URL..." -ForegroundColor Yellow
$createBody = @{
    url = "https://www.google.com"
    owner = "test@example.com"
} | ConvertTo-Json

try {
    $shortUrl = Invoke-RestMethod -Uri "http://localhost:8080/api/v1/shorten" -Method POST -Body $createBody -ContentType "application/json"
    
    Write-Host "Success - Short URL created successfully!" -ForegroundColor Green
    Write-Host "  Original URL: $($shortUrl.originalUrl)" -ForegroundColor Cyan
    Write-Host "  Short Code: $($shortUrl.shortCode)" -ForegroundColor Cyan
    Write-Host "  Short URL: $($shortUrl.shortUrl)" -ForegroundColor Cyan
    Write-Host "  Owner: $($shortUrl.owner)" -ForegroundColor Cyan
    
    $global:shortCode = $shortUrl.shortCode
}
catch {
    Write-Host "Failed - Could not create short URL: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 4: Get Analytics
Write-Host "`n[TEST 4] Get Analytics..." -ForegroundColor Yellow
try {
    $analytics = Invoke-RestMethod -Uri "http://localhost:8080/api/v1/urls/$global:shortCode/analytics" -Method GET
    
    Write-Host "Success - Analytics retrieved successfully!" -ForegroundColor Green
    Write-Host "  Short Code: $($analytics.shortCode)" -ForegroundColor Cyan
    Write-Host "  Click Count: $($analytics.clickCount)" -ForegroundColor Cyan
    Write-Host "  Created At: $($analytics.createdAt)" -ForegroundColor Cyan
}
catch {
    Write-Host "Failed - Could not get analytics: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 5: Swagger Documentation
Write-Host "`n[TEST 5] Swagger Documentation..." -ForegroundColor Yellow
try {
    $swagger = Invoke-WebRequest -Uri "http://localhost:8080/swagger-ui.html" -UseBasicParsing -TimeoutSec 5
    Write-Host "Success - Swagger UI accessible (Status: $($swagger.StatusCode))" -ForegroundColor Green
}
catch {
    Write-Host "Failed - Swagger UI not accessible: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 6: Redis Cache Check
Write-Host "`n[TEST 6] Redis Cache Verification..." -ForegroundColor Yellow
$redisCheck = docker exec urlshortener-redis redis-cli KEYS "short:*" 2>$null
if ($redisCheck) {
    Write-Host "Success - Redis cache working" -ForegroundColor Green
    Write-Host "  Cached keys found: $redisCheck" -ForegroundColor Cyan
}
else {
    Write-Host "Info - Redis cache is empty (will be populated on redirect)" -ForegroundColor Yellow
}

# Test 7: Database Tables Check
Write-Host "`n[TEST 7] Database Tables Verification..." -ForegroundColor Yellow
$tables = docker exec urlshortener-mysql mysql -u urluser -purlpassword urlshortener -e "SHOW TABLES;" 2>$null
if ($tables) {
    Write-Host "Success - Database tables created:" -ForegroundColor Green
    Write-Host $tables -ForegroundColor Cyan
}

# Test 8: Create Another Short URL
Write-Host "`n[TEST 8] Create Another Short URL with Expiry..." -ForegroundColor Yellow
$createBody2 = @{
    url = "https://github.com"
    owner = "developer@example.com"
    expiryDate = "2025-12-31T23:59:59"
} | ConvertTo-Json

try {
    $shortUrl2 = Invoke-RestMethod -Uri "http://localhost:8080/api/v1/shorten" -Method POST -Body $createBody2 -ContentType "application/json"
    
    Write-Host "Success - Short URL with expiry created!" -ForegroundColor Green
    Write-Host "  Short Code: $($shortUrl2.shortCode)" -ForegroundColor Cyan
    Write-Host "  Expiry Date: $($shortUrl2.expiryDate)" -ForegroundColor Cyan
}
catch {
    Write-Host "Failed - Could not create short URL: $($_.Exception.Message)" -ForegroundColor Red
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Test Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Application URLs:" -ForegroundColor Green
Write-Host "  Frontend:  http://localhost:3000" -ForegroundColor White
Write-Host "  Backend:   http://localhost:8080" -ForegroundColor White
Write-Host "  Swagger:   http://localhost:8080/swagger-ui.html" -ForegroundColor White
Write-Host "  Health:    http://localhost:8080/actuator/health" -ForegroundColor White
Write-Host ""
Write-Host "Your test short URL: http://localhost:8080/$global:shortCode" -ForegroundColor Green
Write-Host "Analytics:           http://localhost:8080/api/v1/urls/$global:shortCode/analytics" -ForegroundColor White
Write-Host ""
Write-Host "All tests completed!" -ForegroundColor Green
Write-Host ""
