# Flutter Development Script - Cu Hot Reload Manual
# Pornește Flutter și permite hot reload cu tasta 'r'

$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") + ";C:\flutter\bin"

$projectPath = "C:\Users\Home\loco-instant-complete-automation-e2e.git\loco-instant-complete-automation-e2e\frontend\loco_instant_flutter"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  LOCO Instant - Flutter Development   " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Comenzi disponibile in timpul rularii:" -ForegroundColor Yellow
Write-Host "  r - Hot reload (update rapid)" -ForegroundColor White
Write-Host "  R - Hot restart (restart complet)" -ForegroundColor White
Write-Host "  q - Opreste aplicatia" -ForegroundColor White
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Set-Location $projectPath
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000

