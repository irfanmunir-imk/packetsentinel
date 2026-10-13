#!/usr/bin/env sh
# Build a native single-file executable on Linux/macOS (the .exe must be built on Windows with build_exe.bat)
set -e
cd "$(dirname "$0")"
python3 -m pip install --upgrade pyinstaller
python3 -m PyInstaller --onefile --name PacketSentinel main.py
echo "Built: dist/PacketSentinel"
