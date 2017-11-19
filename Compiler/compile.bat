set /p target=Enter Target: 
%~dp0..\Compiler\dasm %~dp0..\Code\%target%.asm -f3 -o%~dp0..\Bin\%target%.bin
pause