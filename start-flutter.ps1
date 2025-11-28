$flutterPath = "C:\Users\adina.traica\loco-instant-complete-automation-e2e\frontend\loco_instant_flutter"

if (-not (Test-Path $flutterPath)) {
  Write-Host "Flutter app path not found: $flutterPath" -ForegroundColor Red
  exit 1
}

Write-Host "Starting Flutter app in a new PowerShell window..." -ForegroundColor Cyan
Start-Process powershell -NoExit -Command "cd '$flutterPath'; flutter pub get; flutter run"

Write-Host "Flutter launch command issued." -ForegroundColor Green
