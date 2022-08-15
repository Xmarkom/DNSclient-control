@echo off
mode con:cols=70 lines=32
SETLOCAL ENABLEDELAYEDEXPANSION

rem CMD skript pre zapnutie/vypnutie sluzby "DNS client" vo Windows 10
rem Metoda uprava hodnota registra
rem Created by Marek M@rko # 2019
rem Lang:SVK

call :_checkPermiss
color 1E
Title DNSclient_control v1.0
call :_LOGO
call :_checkOS
set state=0
call :_checkServ
echo:
echo:
echo ^			## Ukonci program lubovolnou klavesou ##
pause >nul
exit



:_LOGO
rem ________________________________________________
echo:
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
	echo  ^> Kontrola verzie OS Windows:
	echo:
	@timeout /t 1 > nul
	setlocal
	for /f "tokens=4-5 delims=. " %%i in ('ver') do set version=%%i.%%j
	if "%version%" == "10.0" ( 
		echo  ^> Verzia %version% ........OK
		echo:
		@timeout /t 1 > nul
		echo  ^> Opravnenia administratora .... OK
		echo:
		exit /B
	) else ( 
		echo  ^> Verzia %version%
		echo  ^> Nepodporovana verzia OS !
		echo:
		echo  ^			## Ukonci program lubovolnou klavesou ##
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
	echo  ^> Kontrola sluzby "DNSclient":
	@timeout /t 1 > nul
	set _cmd=WMIC Service WHERE "Name = 'Dnscache'" GET Started /format:list
	echo:
	for /f "tokens=2 delims==" %%i in ('%_cmd%') do set a=%%i
	if "%a%" == "FALSE" (
		:: 2 (Automatic) (DEFAULT)
		set %state%=2       
		echo  ^> 	...Sluzba DNSclient je vypnuta.
		echo:
		@timeout /t 1 > nul
		echo  ^> Nastavujem sluzbu na automaticke spustenie....
		call :_SCset
	) else ( 
		:: 4 (Disabled)
		set %state%=4 
		echo  ^> 	...Sluzba DNSclient je zapnuta.
		echo:
		@timeout /t 1 > nul
		echo  ^> Vypinam sluzbu DNSclient....
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
	echo  ^> Prosim restartujte PC
    exit /B