::@echo off

:: This script renames built-in admin and guest accounts into admin and guest
:: respectively from whatever they are. Idea is that the names are system
:: language dependent while the SIDs are well-known. It also renames (some)
:: built-in groups. See http://support.microsoft.com/kb/243330/en

:: Refusing to work on Windows XP Home
wmic exit || exit /b 1

:: users
wmic useraccount where 'sid like "S-1-5-21-%%-500"' call rename admin
wmic useraccount where 'sid like "S-1-5-21-%%-501"' call rename guest

:: groups
wmic group where sid="S-1-5-32-544" call rename admins
wmic group where sid="S-1-5-32-578" call rename hvadmins
wmic group where sid="S-1-5-32-546" call rename guests
wmic group where sid="S-1-5-32-569" call rename cryptoops
wmic group where sid="S-1-5-32-551" call rename backupops
wmic group where sid="S-1-5-32-547" call rename powerusers 
wmic group where sid="S-1-5-32-545" call rename users
wmic group where sid="s-1-5-32-562" call rename dcom
wmic group where sid="S-1-5-32-555" call rename rdp
wmic group where sid="S-1-5-32-580" call rename winrm
