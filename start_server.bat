@echo off
echo Starting Laravel Server...
cd backend
php artisan serve --host=0.0.0.0 --port=9020
pause
