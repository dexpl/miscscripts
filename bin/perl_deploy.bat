@echo off

setlocal enabledelayedexpansion
set perlver=5.30.0.1
:: %1 may either be a Perl version or a path to an *.msi file
if not "%1"=="" (if exist "%1" (set perlurl="%1") else (set perlver=%1))

net file || (echo Got root?>&2 & exit /b 1)
if "!perlurl!"=="" (
	if "%PROCESSOR_ARCHITECTURE%"=="x86" set perlarch=32bit
	if "%PROCESSOR_ARCHITECTURE%"=="AMD64" set perlarch=64bit
	if "!perlarch!"=="" (echo Unknown CPU arch, stopping>&2 & exit /b 2)
	set perlurl=http://strawberryperl.com/download/!perlver!/strawberry-perl-!perlver!-!perlarch!.msi
)

echo on
start "" /w msiexec /i !perlurl! /log "%userprofile%\%~n0.log" /passive /norestart
