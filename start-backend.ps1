param(
  [switch]$NoDocker
)

$backendPath = "C:\Users\adina.traica\loco-instant-complete-automation-e2e\backend"

if (-not (Test-Path $backendPath)) {
  Write-Host "Backend path not found: $backendPath" -ForegroundColor Red
  exit 1
}

if (-not $NoDocker) {
  Write-Host "Starting local infra (Postgres, Redis, OpenSearch) via docker-compose..." -ForegroundColor Cyan
  Set-Location $backendPath
  docker-compose -f docker-compose.local.yml up -d
}

Write-Host "Starting NestJS backend (start:dev) in a new PowerShell window..." -ForegroundColor Cyan
Start-Process powershell -NoExit -Command "cd '$backendPath'; npm run start:dev"

Write-Host "Backend launch command issued." -ForegroundColor Green
