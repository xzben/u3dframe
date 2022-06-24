@echo off
for /f "delims=" %%i in ('dir /b "*.proto"') do protoc -o../pb/%%~ni.pb %%i
pause
