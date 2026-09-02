@echo off
setlocal
set OMP_NUM_THREADS=1
set OPENBLAS_NUM_THREADS=1
cd /d "%~dp0backend"

echo Checking port 8000...
netstat -ano | findstr /R /C:":8000 .*LISTENING" >nul
if not errorlevel 1 (
  powershell -NoProfile -Command ^
    "try { $h=Invoke-RestMethod 'http://127.0.0.1:8000/health' -TimeoutSec 2; if ($h.status -eq 'ok' -and $h.api_version) { exit 0 } } catch {}; exit 1"
  if not errorlevel 1 (
    echo Nirapod AI backend is already running on port 8000.
    exit /b 0
  )
  echo ERROR: Port 8000 is being used by another application.
  echo Close that application or configure a different backend port.
  pause
  exit /b 1
)

if not exist ".venv\Scripts\python.exe" (
  where python >nul 2>nul
  if errorlevel 1 (
    echo ERROR: Python was not found in PATH.
    echo Install Python 3.12 or 3.13 from https://www.python.org/downloads/
    echo During installation, select "Add python.exe to PATH", then reopen this window.
    pause
    exit /b 1
  )
  echo Preparing the Python backend for first use...
  python -m venv .venv
  if errorlevel 1 goto :venv_error
  call .venv\Scripts\activate.bat
  python -m pip install --upgrade pip
  python -m pip install -r requirements.txt
  if errorlevel 1 goto :dependency_error
)

call .venv\Scripts\activate.bat
echo Starting Nirapod AI backend at http://127.0.0.1:8000
echo API documentation: http://127.0.0.1:8000/docs
python -m uvicorn main:app --host 0.0.0.0 --port 8000
exit /b %errorlevel%

:venv_error
echo ERROR: Python could not create the virtual environment.
pause
exit /b 1

:dependency_error
echo ERROR: Backend dependencies could not be installed.
pause
exit /b 1
