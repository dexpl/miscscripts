@echo off

powershell -NoLogo -Command "& {Set-NetConnectionProfile -NetworkCategory Private}"
call winrm quickconfig -q -force
# https://github.com/ansible/ansible/issues/42978
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /f /v LocalAccountTokenFilterPolicy /d 1 /t REG_DWORD
wmic computersystem where name="%computername%" get partofdomain /format:value | findstr -c:"^partofdomain=true$" -ir && exit /b
call winrm set winrm/config/service @{AllowUnencrypted="true"}
:: Allow basic auth only on non-AD machines
call winrm set winrm/config/service/auth @{Basic="true"}
