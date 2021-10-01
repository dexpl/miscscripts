@echo off

powershell -NoLogo -Command "& {Set-NetConnectionProfile -NetworkCategory Private}"
call winrm quickconfig -q -force
wmic computersystem where name="%computername%" get partofdomain /format:value | findstr -c:"^partofdomain=true$" -ir && exit /b
call winrm set winrm/config/service @{AllowUnencrypted="true"}
:: Allow basic auth only on non-AD machines
call winrm set winrm/config/service/auth @{Basic="true"}
