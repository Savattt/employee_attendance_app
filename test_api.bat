@echo off
echo Testing API endpoints...
echo.
echo Testing /api/test...
powershell -Command "Invoke-WebRequest -Uri 'http://127.0.0.1:9020/api/test' -Method GET"
echo.
echo Testing /api/leaves...
powershell -Command "Invoke-WebRequest -Uri 'http://127.0.0.1:9020/api/leaves' -Headers @{'x-dev-uid'='test-user'} -Method GET"
echo.
pause
