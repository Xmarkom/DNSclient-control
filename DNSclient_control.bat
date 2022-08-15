@echo off
mode con:cols=70 lines=32
SETLOCAL ENABLEDELAYEDEXPANSION

rem CMD script for enable/disable the "DNS client" service in Windows 10
rem Registry key modifying method
rem Created by Marek M@rko # 2019

call :_checkPermiss
color 1E
Title DNSclient_control v1.0
call :_LOGO
call :_checkOS
set state=0
call :_checkServ
echo:
echo:
echo ^			## Exit the program with any key ##
pause >nul
exit




:_LOGO
rem ________________________________________________
echo:
echo 	 ######  #     #  #####  
echo 	 #     # ##    # #     # 
echo 	 #     # # #   # #       
echo 	 #     # #  #  #  #####  
echo 	 #     # #   # #       # 
echo 	 #     # #    ## #     # 
echo 	 ######  #     #  #####  control v.1
echo: 
echo    	       [ written by Marek M@rko # 2019 ]
echo:
echo:
exit /B



:_checkOS
rem ________________________________________________
	@timeout /t 1 > nul
	echo  ^> Checking the OS Windows version:
	echo:
	@timeout /t 1 > nul
	setlocal
	for /f "tokens=4-5 delims=. " %%i in ('ver') do set version=%%i.%%j
	if "%version%" == "10.0" ( 
		echo  ^> Version %version% ........OK
		echo:
		@timeout /t 1 > nul
		echo  ^> Administrator rights .... OK
		echo:
		exit /B
	) else ( 
		echo  ^> Version %version%
		echo  ^> Unsupported version of OS !
		echo:
		echo  ^			## Exit the program with any key ##
		pause >nul
		endlocal
		exit
	)




:_checkPermiss
rem ________________________________________________
    net session >nul 2>&1
    if %errorLevel% == 0 (
		exit /B
    ) else (
		cls
        goto _getAdmin
    )   


:_getAdmin
rem ______________________________________________________________________________
	echo Set UAC = CreateObject^("Shell.Application"^) > "%TEMP%\getadmin.vbs"
	set params= %*
	echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%TEMP%\getadmin.vbs"
	wscript.exe "%TEMP%\getadmin.vbs"
	del "%TEMP%\getadmin.vbs"
	exit




:_checkServ
rem ________________________________________________
	@timeout /t 1 > nul
	echo:
	echo  ^> Checking service "DNSclient":
	@timeout /t 1 > nul
	set _cmd=WMIC Service WHERE "Name = 'Dnscache'" GET Started /format:list
	echo:
	for /f "tokens=2 delims==" %%i in ('%_cmd%') do set a=%%i
	if "%a%" == "FALSE" (
		:: 2 (Automatic) (DEFAULT)
		set %state%=2       
		echo  ^> ...Service DNSclient is disabled.
		echo:
		@timeout /t 1 > nul
		echo  ^> Setting the service to automatically running....
		call :_SCset
	) else ( 
		:: 4 (Disabled)
		set %state%=4 
		echo  ^> ...Service DNSclient is enable.
		echo:
		@timeout /t 1 > nul
		echo  ^> Disabled service....
		call :_SCset
	)
	endlocal
	exit /B




:_SCset
rem ________________________________________________
	@timeout /t 1 > nul
	echo:
	reg add "HKLM\SYSTEM\CurrentControlSet\services\Dnscache" /v Start /t REG_DWORD /d %state% /f
	echo:
	echo  ^> Please restart PC...
    exit /B