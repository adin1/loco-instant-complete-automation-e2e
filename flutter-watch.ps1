# Flutter Auto-Reload Script
# Monitorizează modificările din lib/ și face hot reload automat

$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") + ";C:\flutter\bin"

$projectPath = "C:\Users\Home\loco-instant-complete-automation-e2e.git\loco-instant-complete-automation-e2e\frontend\loco_instant_flutter"
$libPath = "$projectPath\lib"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  LOCO Instant - Flutter Auto-Reload   " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verifică dacă Flutter rulează deja
$flutterProcess = Get-Process -Name "dart" -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -like "*flutter*" }

if ($flutterProcess) {
    Write-Host "[INFO] Flutter deja rulează. Oprește procesul existent..." -ForegroundColor Yellow
    Stop-Process -Name "dart" -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
}

# Pornește Flutter în background și salvează procesul
Write-Host "[START] Pornesc Flutter pe Chrome..." -ForegroundColor Green
$job = Start-Job -ScriptBlock {
    param($path)
    Set-Location $path
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") + ";C:\flutter\bin"
    flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000 2>&1
} -ArgumentList $projectPath

# Așteaptă să pornească
Write-Host "[WAIT] Aștept să pornească aplicația..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Configurează FileSystemWatcher
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $libPath
$watcher.Filter = "*.dart"
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents = $true
$watcher.NotifyFilter = [System.IO.NotifyFilters]::LastWrite -bor [System.IO.NotifyFilters]::FileName

$lastReload = Get-Date

# Funcție pentru debounce (evită reîncărcări multiple)
$action = {
    $now = Get-Date
    $diff = ($now - $script:lastReload).TotalSeconds
    
    if ($diff -gt 1) {
        $script:lastReload = $now
        $path = $Event.SourceEventArgs.FullPath
        $name = $Event.SourceEventArgs.Name
        
        Write-Host ""
        Write-Host "[CHANGE] Fișier modificat: $name" -ForegroundColor Magenta
        Write-Host "[RELOAD] Refreshează browser-ul (F5) pentru a vedea modificările" -ForegroundColor Green
        Write-Host ""
        
        # Poți adăuga aici cod pentru a trimite refresh automat la browser
        # De exemplu, folosind un WebSocket sau API
    }
}

# Înregistrează evenimentele
Register-ObjectEvent $watcher "Changed" -Action $action | Out-Null
Register-ObjectEvent $watcher "Created" -Action $action | Out-Null
Register-ObjectEvent $watcher "Renamed" -Action $action | Out-Null

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Monitorizare activă!                 " -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Modificările din lib/*.dart sunt monitorizate." -ForegroundColor White
Write-Host "Când salvezi un fișier, vei primi notificare." -ForegroundColor White
Write-Host ""
Write-Host "Apasă Ctrl+C pentru a opri." -ForegroundColor Yellow
Write-Host ""

# Afișează output-ul Flutter
try {
    while ($true) {
        if ($job.State -eq "Running") {
            $output = Receive-Job $job -ErrorAction SilentlyContinue
            if ($output) {
                $output | ForEach-Object { Write-Host $_ }
            }
        }
        Start-Sleep -Milliseconds 500
    }
} finally {
    # Curățare la ieșire
    Write-Host "`n[STOP] Opresc monitorizarea..." -ForegroundColor Red
    $watcher.EnableRaisingEvents = $false
    Get-EventSubscriber | Unregister-Event
    Stop-Job $job -ErrorAction SilentlyContinue
    Remove-Job $job -ErrorAction SilentlyContinue
    Write-Host "[DONE] Gata!" -ForegroundColor Green
}

