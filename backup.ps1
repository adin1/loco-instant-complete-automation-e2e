# ============================================
# LOCO INSTANT - BACKUP & RESTORE SCRIPT
# ============================================

param(
    [Parameter(Position=0)]
    [string]$Action = "backup",
    
    [Parameter(Position=1)]
    [string]$TagName = ""
)

$projectPath = "C:\Users\Home\loco-instant-complete-automation-e2e.git\loco-instant-complete-automation-e2e"
$backupPath = "C:\Users\Home\loco-instant-backups"

# Creează folder backup dacă nu există
if (!(Test-Path $backupPath)) {
    New-Item -ItemType Directory -Path $backupPath -Force | Out-Null
}

function Create-Backup {
    $timestamp = Get-Date -Format "yyyy-MM-dd-HHmm"
    $backupName = "backup-$timestamp"
    
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "  CREEZ BACKUP: $backupName" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    
    # 1. Git tag
    Set-Location $projectPath
    git add -A
    git commit -m "Auto-backup: $timestamp" --allow-empty
    git tag -a $backupName -m "Backup point: $timestamp"
    git push origin --tags
    
    # 2. Local backup (zip)
    $zipPath = "$backupPath\$backupName.zip"
    Compress-Archive -Path "$projectPath\*" -DestinationPath $zipPath -Force
    
    Write-Host ""
    Write-Host "✅ Backup creat cu succes!" -ForegroundColor Green
    Write-Host "   Git tag: $backupName" -ForegroundColor White
    Write-Host "   Local: $zipPath" -ForegroundColor White
    Write-Host ""
    
    # 3. Afișează ultimele 5 backup-uri
    Write-Host "Ultimele backup-uri disponibile:" -ForegroundColor Yellow
    git tag -l "backup-*" | Select-Object -Last 5
}

function List-Backups {
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "  BACKUP-URI DISPONIBILE" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    
    Set-Location $projectPath
    Write-Host ""
    Write-Host "Git Tags:" -ForegroundColor Yellow
    git tag -l "backup-*"
    
    Write-Host ""
    Write-Host "Local Backups:" -ForegroundColor Yellow
    Get-ChildItem $backupPath -Filter "*.zip" | ForEach-Object {
        Write-Host "  $($_.Name) - $($_.LastWriteTime)"
    }
}

function Restore-Backup {
    param([string]$tag)
    
    if ([string]::IsNullOrEmpty($tag)) {
        Write-Host "Eroare: Specificați tag-ul pentru restore" -ForegroundColor Red
        Write-Host "Exemplu: .\backup.ps1 restore backup-2025-12-01-1924" -ForegroundColor Yellow
        return
    }
    
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "  RESTORE LA: $tag" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    
    Set-Location $projectPath
    
    # Confirmă
    $confirm = Read-Host "Ești sigur că vrei să restaurezi la $tag? (da/nu)"
    if ($confirm -ne "da") {
        Write-Host "Restore anulat." -ForegroundColor Yellow
        return
    }
    
    # Creează backup curent înainte de restore
    $currentBackup = "pre-restore-$(Get-Date -Format 'yyyy-MM-dd-HHmm')"
    git tag -a $currentBackup -m "Auto-backup before restore to $tag"
    
    # Restore
    git checkout $tag
    
    Write-Host ""
    Write-Host "✅ Restaurat la $tag" -ForegroundColor Green
    Write-Host "   Backup curent salvat ca: $currentBackup" -ForegroundColor White
}

# Main
switch ($Action.ToLower()) {
    "backup" { Create-Backup }
    "list" { List-Backups }
    "restore" { Restore-Backup -tag $TagName }
    default {
        Write-Host "Utilizare:" -ForegroundColor Yellow
        Write-Host "  .\backup.ps1 backup     - Creează un backup nou"
        Write-Host "  .\backup.ps1 list       - Afișează backup-urile disponibile"
        Write-Host "  .\backup.ps1 restore <tag> - Restaurează la un backup"
    }
}

