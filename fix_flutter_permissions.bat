@echo off
echo Fixing Flutter permission issues...

REM Close any running Flutter processes
taskkill /F /IM flutter.exe /T 2>nul
taskkill /F /IM dart.exe /T 2>nul

REM Remove problematic directories
echo Removing Flutter ephemeral directories...
if exist "windows\flutter\ephemeral" (
  rmdir /S /Q "windows\flutter\ephemeral"
  echo Removed ephemeral directory.
) else (
  echo Ephemeral directory not found.
)

REM Clean Flutter cache
echo Cleaning Flutter cache...
if exist ".dart_tool" rmdir /S /Q ".dart_tool"
if exist ".flutter-plugins" del /F /Q ".flutter-plugins"
if exist ".flutter-plugins-dependencies" del /F /Q ".flutter-plugins-dependencies"
if exist ".packages" del /F /Q ".packages"
if exist "build" rmdir /S /Q "build"
if exist ".pub-cache" rmdir /S /Q ".pub-cache"

echo Done! Now try running:
echo flutter pub get
echo flutter run

pause
