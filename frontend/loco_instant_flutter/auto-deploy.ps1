# ============================================================
# AUTO-DEPLOY SCRIPT pentru LOCO-INSTANT.RO
# Monitorizează modificări și face deploy automat
# ============================================================

param(
    [switch]$Watch,      # Mod watch continuu
    [switch]$Once        # Deploy o singură dată
)

$ErrorActionPreference = "Continue"

# Configurare
$FlutterPath = "C:\flutter\bin"
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$FlutterDir = $PSScriptRoot
$LibDir = Join-Path $FlutterDir "lib"
$ApiUrl = "https://loco-backend.onrender.com"

# Adaugă Flutter la PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") + ";$FlutterPath"

# Culori pentru output
function Write-Success { param($msg) Write-Host "✅ $msg" -ForegroundColor Green }
function Write-Info { param($msg) Write-Host "ℹ️  $msg" -ForegroundColor Cyan }
function Write-Warning { param($msg) Write-Host "⚠️  $msg" -ForegroundColor Yellow }
function Write-Error { param($msg) Write-Host "❌ $msg" -ForegroundColor Red }
function Write-Step { param($msg) Write-Host "`n🔄 $msg" -ForegroundColor Magenta }

# Funcție de deploy
function Deploy-ToLocoInstant {
    $startTime = Get-Date
    
    Write-Step "PORNIRE DEPLOY LOCO-INSTANT.RO"
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    
    # 1. Build Flutter Web
    Write-Info "Build Flutter Web (release)..."
    Set-Location $FlutterDir
    
    $buildResult = flutter build web --release --dart-define=API_BASE_URL=$ApiUrl 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Build FAILED!"
        Write-Host $buildResult -ForegroundColor Red
        return $false
    }
    Write-Success "Build complet"
    
    # 2. Adaugă CNAME
    Write-Info "Adăugare CNAME..."
    "loco-instant.ro" | Out-File -FilePath (Join-Path $FlutterDir "build\web\CNAME") -Encoding ascii -NoNewline
    Write-Success "CNAME adăugat"
    
    # 3. Git commit și push
    Write-Info "Git commit și push..."
    Set-Location $ProjectRoot
    
    $timestamp = Get-Date -Format "HH:mm:ss"
    git add -A 2>&1 | Out-Null
    
    $commitResult = git commit -m "auto-deploy: Update $timestamp" 2>&1
    if ($commitResult -match "nothing to commit") {
        Write-Warning "Nicio modificare de comis"
        return $true
    }
    
    $pushResult = git push 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Git push FAILED!"
        Write-Host $pushResult -ForegroundColor Red
        return $false
    }
    Write-Success "Push la GitHub complet"
    
    # 4. Calcul durată
    $duration = (Get-Date) - $startTime
    $durationStr = "{0:mm}:{0:ss}" -f $duration
    
    Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    Write-Success "DEPLOY COMPLET în $durationStr"
    Write-Info "GitHub Actions va publica pe loco-instant.ro în ~2-3 minute"
    Write-Info "Verifică: https://loco-instant.ro"
    Write-Host ""
    
    return $true
}

# Funcție pentru deschidere browser și refresh
function Open-LocoInstant {
    Write-Info "Deschidere loco-instant.ro în browser..."
    Start-Process "https://loco-instant.ro"
}

# MOD WATCH - Monitorizare continuă
function Start-FileWatcher {
    Write-Host @"

╔══════════════════════════════════════════════════════════════╗
║           AUTO-DEPLOY LOCO-INSTANT.RO                        ║
║                                                              ║
║   Monitorizez modificări în:                                 ║
║   $LibDir
║                                                              ║
║   La fiecare salvare → Build → Push → Deploy                 ║
║                                                              ║
║   Apasă Ctrl+C pentru a opri                                 ║
╚══════════════════════════════════════════════════════════════╝

"@ -ForegroundColor Cyan

    # Creează FileSystemWatcher
    $watcher = New-Object System.IO.FileSystemWatcher
    $watcher.Path = $LibDir
    $watcher.Filter = "*.dart"
    $watcher.IncludeSubdirectories = $true
    $watcher.EnableRaisingEvents = $false
    
    # Debounce - evită deploy-uri multiple pentru aceeași modificare
    $lastDeployTime = [DateTime]::MinValue
    $debounceSeconds = 5
    
    Write-Success "Watcher activ! Aștept modificări..."
    Write-Host ""
    
    try {
        while ($true) {
            # Verifică pentru modificări (poll la fiecare 2 secunde)
            $result = $watcher.WaitForChanged([System.IO.WatcherChangeTypes]::Changed -bor [System.IO.WatcherChangeTypes]::Created, 2000)
            
            if ($result.TimedOut) {
                continue
            }
            
            # Debounce check
            $now = Get-Date
            $timeSinceLastDeploy = ($now - $lastDeployTime).TotalSeconds
            
            if ($timeSinceLastDeploy -lt $debounceSeconds) {
                Write-Warning "Modificare detectată, dar aștept debounce ($debounceSeconds sec)..."
                continue
            }
            
            Write-Host "`n📁 Modificare detectată: $($result.Name)" -ForegroundColor Yellow
            $lastDeployTime = $now
            
            # Așteaptă puțin pentru salvări multiple
            Start-Sleep -Seconds 2
            
            # Deploy
            Deploy-ToLocoInstant
        }
    }
    finally {
        $watcher.Dispose()
        Write-Info "Watcher oprit."
    }
}

# MAIN
Write-Host @"

  _     ___   ____ ___    ___ _   _ ____ _____  _    _   _ _____ 
 | |   / _ \ / ___/ _ \  |_ _| \ | / ___|_   _|/ \  | \ | |_   _|
 | |  | | | | |  | | | |  | ||  \| \___ \ | | / _ \ |  \| | | |  
 | |__| |_| | |__| |_| |  | || |\  |___) || |/ ___ \| |\  | | |  
 |_____\___/ \____\___/  |___|_| \_|____/ |_/_/   \_\_| \_| |_|  
                                                                 
              AUTO-DEPLOY SCRIPT v1.0

"@ -ForegroundColor Cyan

if ($Once) {
    # Deploy o singură dată
    Deploy-ToLocoInstant
    Open-LocoInstant
}
elseif ($Watch) {
    # Mod watch continuu
    Start-FileWatcher
}
else {
    # Default: arată help
    Write-Host @"
Utilizare:
  .\auto-deploy.ps1 -Once     # Deploy o singură dată și deschide browser
  .\auto-deploy.ps1 -Watch    # Monitorizare continuă + auto-deploy

Exemple:
  # Deploy rapid:
  .\auto-deploy.ps1 -Once

  # Lasă să ruleze în background și modifică fișierele:
  .\auto-deploy.ps1 -Watch

"@ -ForegroundColor White
}

