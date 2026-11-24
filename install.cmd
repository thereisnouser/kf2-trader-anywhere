@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1" %*
set "result=%ERRORLEVEL%"
if not "%result%"=="0" echo Installation failed. See the error above.
pause
exit /b %result%
