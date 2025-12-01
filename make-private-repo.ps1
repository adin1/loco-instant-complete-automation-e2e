# ==============================================
# SCRIPT: Creează repository privat nou
# ==============================================

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  LOCO INSTANT - Creează Repo Privat" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Instrucțiuni
Write-Host "PAȘI pentru a face repository-ul PRIVAT:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Mergi la: https://github.com/adin1/loco-instant-complete-automation-e2e" -ForegroundColor White
Write-Host "2. Click pe Settings (⚙️)" -ForegroundColor White
Write-Host "3. Scroll până la 'Danger Zone'" -ForegroundColor White
Write-Host "4. Click 'Change repository visibility'" -ForegroundColor White
Write-Host "5. Selectează 'Make private'" -ForegroundColor White
Write-Host "6. Confirmă scriind numele repo-ului" -ForegroundColor White
Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "SAU creează un repo NOU privat:" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "1. Mergi la: https://github.com/new" -ForegroundColor White
Write-Host "2. Nume: loco-instant-private" -ForegroundColor White
Write-Host "3. Bifează: Private" -ForegroundColor White
Write-Host "4. Click: Create repository" -ForegroundColor White
Write-Host ""
Write-Host "Apoi rulează:" -ForegroundColor Yellow
Write-Host "git remote set-url origin https://github.com/adin1/loco-instant-private.git" -ForegroundColor Cyan
Write-Host "git push -u origin main --force" -ForegroundColor Cyan
Write-Host ""

# Opțional: Șterge istoria Git pentru a elimina toate versiunile vechi
Write-Host "============================================" -ForegroundColor Red
Write-Host "OPȚIONAL: Șterge istoria Git (dacă vrei să ștergi toate commit-urile vechi)" -ForegroundColor Red
Write-Host "============================================" -ForegroundColor Red
Write-Host ""
Write-Host "ATENȚIE: Aceasta șterge toată istoria!" -ForegroundColor Red
Write-Host ""
Write-Host "git checkout --orphan temp_branch" -ForegroundColor Cyan
Write-Host "git add -A" -ForegroundColor Cyan
Write-Host "git commit -m 'Initial commit - fresh start'" -ForegroundColor Cyan
Write-Host "git branch -D main" -ForegroundColor Cyan
Write-Host "git branch -m main" -ForegroundColor Cyan
Write-Host "git push origin main --force" -ForegroundColor Cyan

