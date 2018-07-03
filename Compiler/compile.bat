@ECHO OFF

ECHO "|---------------------------------------------|"
ECHO "|      _    ________    _       ______    __  |"
ECHO "|     / \  |__    __|  / \     |   _  \  |  | |"
ECHO "|    / . \    |  |    / . \    |  |_) /  |  | |"
ECHO "|   / /_\ \   |  |   / /_\ \   |     (   |  | |"
ECHO "|  /  ___  \  |  |  /  ___  \  |  |\  \  |  | |"
ECHO "| /__/   \__\ |__| /__/   \__\ |__| \__\ |__| |"
ECHO "|                                             |"
ECHO "|---------------------------------------------|"
ECHO.

:BEGIN 

for /f %%f in ('dir /b "%~dp0..\Code\Gyms\"') do "%~dp0..\Compiler\dasm" "%~dp0..\Code\Gyms\%%f" -f3 -o"%~dp0..\Bin\Gyms\%%f.bin"
for /f %%f in ('dir /b "%~dp0..\Code\Phazer\"') do "%~dp0..\Compiler\dasm" "%~dp0..\Code\Phazer\%%f" -f3 -o"%~dp0..\Bin\Phazer\%%f.bin"

PAUSE

ECHO.
GOTO :BEGIN