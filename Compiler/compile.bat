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
ECHO. 1) Hello World
ECHO. 2) Playfield
ECHO. 3) Pong
ECHO. 4) 500
ECHO. ------------------

SET choice=
SET /P choice=Which source to compile? 

IF NOT '%choice%'=='' SET choice=%choice:~0,1%
IF '%choice%'=='1' SET source=hello
IF '%choice%'=='2' SET source=playfield
IF '%choice%'=='3' SET source=pong
IF '%choice%'=='4' SET source=500

%~dp0..\Compiler\dasm %~dp0..\Code\%source%.asm -f3 -o%~dp0..\Bin\%source%.bin

ECHO.
GOTO :BEGIN