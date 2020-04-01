@echo off

sc config termservice start= auto
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /d 0 /t reg_dword /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v AllowRemoteRPC /d 1 /t reg_dword /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\NetCache" /v Enabled /d 0 /t reg_dword /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AllowMultipleTSSessions /d 1 /t reg_dword /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v LogonType /d 1 /t reg_dword /f
netsh firewall set service remotedesktop enable
net /y start termservice
