@echo off
setlocal
cd /d "%~dp0"
start "Nirapod AI Backend" cmd /k call "%~dp0start_backend.bat"
echo Waiting for the database and machine-learning service...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$deadline = (Get-Date).AddMinutes(3);" ^
  "do {" ^
  "  try {" ^
  "    $health = Invoke-RestMethod 'http://127.0.0.1:8000/health' -TimeoutSec 3;" ^
  "    if ($health.status -eq 'ok' -and $health.models.Count -ge 2) { exit 0 }" ^
  "  } catch {" ^
  "    Write-Host 'Backend is still starting...'" ^
  "  };" ^
  "  Start-Sleep -Seconds 2" ^
  "} while ((Get-Date) -lt $deadline);" ^
  "Write-Error 'Backend did not become healthy within three minutes.'; exit 1"
if errorlevel 1 (
  echo ERROR: The backend did not start. Read the backend window for details.
  pause
  exit /b 1
)
flutter pub get
if errorlevel 1 exit /b 1
flutter run
