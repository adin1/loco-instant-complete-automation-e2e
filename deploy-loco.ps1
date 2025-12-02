# ============================================================
# QUICK DEPLOY pentru LOCO-INSTANT.RO
# Rulează: .\deploy-loco.ps1
# ============================================================

$ErrorActionPreference = "Continue"

# Configurare
$FlutterPath = "C:\flutter\bin"
$FlutterDir = Join-Path $PSScriptRoot "frontend\loco_instant_flutter"
$ApiUrl = "https://loco-backend.onrender.com"

# Adaugă Flutter la PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") + ";$FlutterPath"

Write-Host "`n🚀 DEPLOY LOCO-INSTANT.RO" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray

$startTime = Get-Date

# 1. Build
Write-Host "`n[1/3] 🔨 Build Flutter Web..." -ForegroundColor Yellow
Set-Location $FlutterDir
flutter build web --release --dart-define=API_BASE_URL=$ApiUrl
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build FAILED!" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Build OK" -ForegroundColor Green

# 2. CNAME
Write-Host "`n[2/3] 📄 CNAME..." -ForegroundColor Yellow
"loco-instant.ro" | Out-File -FilePath "build\web\CNAME" -Encoding ascii -NoNewline
Write-Host "✅ CNAME OK" -ForegroundColor Green

# 3. Git push
Write-Host "`n[3/3] 📤 Git push..." -ForegroundColor Yellow
Set-Location $PSScriptRoot
git add -A
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
git commit -m "deploy: $timestamp"
git push

if ($LASTEXITCODE -eq 0) {
    $duration = (Get-Date) - $startTime
    Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    Write-Host "✅ DEPLOY COMPLET! ($('{0:mm}:{0:ss}' -f $duration))" -ForegroundColor Green
    Write-Host "🌐 https://loco-instant.ro (refresh în 2-3 min)" -ForegroundColor Cyan
    Write-Host ""
    
    # Deschide browser
    Start-Process "https://loco-instant.ro"
} else {
    Write-Host "❌ Git push FAILED!" -ForegroundColor Red
}

