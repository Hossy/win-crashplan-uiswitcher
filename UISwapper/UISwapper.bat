@ECHO OFF
IF /I "%~1"=="" GOTO :EOF
::Because Windows 8 "Run as administrator" doesn't respect the "Start in" shortcut option, we must CD to the directory the script is located.
CD "%~dp0"
IF NOT EXIST "conf\ui.properties.local" ECHO Local file missing.  Aborting.& PAUSE & GOTO :EOF
IF NOT EXIST "conf\ui.properties.%~1" ECHO ui.properties.%~1 file missing.  Aborting.& PAUSE & GOTO :EOF
TASKKILL /F /IM CrashPlanDesktop.exe /T
COPY /Y "conf\ui.properties.%~1" "conf\ui.properties"
IF /I NOT "%~2"=="" (
	START "PuTTY" "C:\Program Files (x86)\PuTTY\putty.exe" -load "%~2"
	ECHO Establish tunnel then
	PAUSE
)
START "CrashPlan" "CrashPlanDesktop.exe"
