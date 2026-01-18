@echo off
REM WSL ssh wrapper
REM Usage: ssh host [args...]

wsl -d Ubuntu-24.04 -e ssh %*