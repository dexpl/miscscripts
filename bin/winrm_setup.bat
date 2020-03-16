@echo off

powershell -NoLogo -Command "& {Set-NetConnectionProfile -NetworkCategory Private}"
call winrm quickconfig -q -force
call winrm set winrm/config/service @{AllowUnencrypted="true"}
call winrm set winrm/config/service/auth @{Basic="true"}
