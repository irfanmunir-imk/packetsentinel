@echo off
REM ============================================================
REM  Build PacketSentinel.exe (CLI) and PacketSentinel-GUI.exe
REM  Run this on WINDOWS with Python 3.8+ installed (python.org).
REM ============================================================
setlocal
cd /d "%~dp0"
python -m pip install --upgrade pip pyinstaller || goto :err
if exist build rmdir /s /q build
if exist dist rmdir /s /q dist

echo.
echo === Building CLI exe ===
python -m PyInstaller --onefile --console --name PacketSentinel main.py || goto :err

echo.
echo === Building GUI exe ===
python -m PyInstaller --onefile --noconsole --name PacketSentinel-GUI gui_main.py || goto :err

echo.
echo Done. Executables are in the "dist" folder:
dir /b dist
echo.
echo Test:   dist\PacketSentinel.exe demo
goto :eof

:err
echo.
echo BUILD FAILED - check the messages above.
exit /b 1
