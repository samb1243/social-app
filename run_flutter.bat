@echo off
cd /d "C:\Users\kishi\OneDrive\Documents\VS Code personal projects\Claude web app"
flutter pub get
echo.
echo ================================
echo Running analyze...
echo ================================
flutter analyze
pause
