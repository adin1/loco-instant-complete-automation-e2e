@echo off
title LOCO INSTANT - Auto Deploy
cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -File "deploy-loco.ps1"
pause

