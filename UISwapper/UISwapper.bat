@ECHO OFF
SETLOCAL
IF /I "%~1"=="" GOTO :EOF
::::Because Windows 8 "Run as administrator" doesn't respect the "Start in" shortcut option, we must CD to the directory the script is located.
::CD "%~dp0"

::Variables
SET _DP0=%~dp0
SET _SEDEXE=%_DP0%\sed.exe
SET _UIPROP=%_DP0%\..\conf\ui.properties
SET _UIINFO=%ProgramData%\CrashPlan\.ui_info
SET _UIUSERPROP=%ProgramData%\CrashPlan\conf\ui_%USERNAME%.properties
SET _SVCHOST=127.0.0.1
SET _SVCPORT=4243

::Check for dependencies
IF NOT EXIST "%_DP0%\sed.exe" ECHO Can't find sed.exe.  Aborting.& PAUSE & GOTO :EOF

::Check for CrashPlan files
IF NOT EXIST "%_UIPROP%" ECHO Can't find ui.properties file at "%_UIPROP%".  Aborting.& PAUSE & GOTO :EOF
IF NOT EXIST "%_UIINFO%" ECHO Can't find .ui_info file at "%_UIINFO%".  Aborting.& PAUSE & GOTO :EOF
IF NOT EXIST "%_UIUSERPROP%" ECHO Can't find ui_%USERNAME%.properties file at "%_UIUSERPROP%".  Aborting.& PAUSE & GOTO :EOF

::Check for local files
IF NOT EXIST "%_UIPROP%.local" COPY "%_UIPROP%" "%_UIPROP%.local"
IF NOT EXIST "%_UIINFO%.local" COPY "%_UIINFO%" "%_UIINFO%.local"
IF NOT EXIST "%_UIUSERPROP%.local" COPY "%_UIUSERPROP%" "%_UIUSERPROP%.local"

::Process arguments
SET _PUTTY=
SET _UIINFOGUID=
SET _LOCAL=
:args_again
IF /I "%~1"=="/local" (
	SET _LOCAL=TRUE
	SHIFT
)
IF DEFINED _LOCAL IF /I NOT "%~1"=="" ECHO Cannot combine other options with /local.& PAUSE & GOTO :EOF
IF /I "%~1"=="/host" (
	IF DEFINED _LOCAL GOTO :syn
	SET _SVCHOST=%~2
	SHIFT & SHIFT
)
IF /I "%~1"=="/port" (
	SET _SVCPORT=%~2
	SHIFT & SHIFT
)
IF /I "%~1"=="/putty" (
	SET "_PUTTY=%~2"
	SHIFT & SHIFT
)
IF /I "%~1"=="/uiinfoguid" (
	SET _UIINFOGUID=%~2
	SHIFT & SHIFT
)
IF /I "%~1"=="" GOTO :args_done
GOTO :args_again
:args_done

IF NOT DEFINED _LOCAL IF NOT DEFINED _UIINFOGUID ECHO /uiinfoguid is required& PAUSE & GOTO :EOF

::IF NOT EXIST "ui.properties.local" ECHO Local ui.properties file missing.  Aborting.& PAUSE & GOTO :EOF
::IF NOT EXIST ".ui_info.local" ECHO Local .ui_info file missing.  Aborting.& PAUSE & GOTO :EOF
::IF NOT EXIST "ui_USERNAME.properties.local" ECHO Local ui_USERNAME.properties.local file missing.  Aborting.& PAUSE & GOTO :EOF
::IF NOT EXIST "ui.properties.%~1" ECHO ui.properties.%~1 file missing.  Aborting.& PAUSE & GOTO :EOF
::IF NOT EXIST ".ui_info.%~1" ECHO .ui_info.%~1 file missing.  Aborting.& PAUSE & GOTO :EOF
::IF NOT EXIST "ui_USERNAME.properties.%~1" ECHO Local ui_USERNAME.properties.%~1 file missing.  Aborting.& PAUSE & GOTO :EOF

::Close CrashPlanDesktop (UI)
TASKKILL /F /IM CrashPlanDesktop.exe /T

::Update UI files
IF DEFINED _LOCAL (
	COPY /Y "%_UIPROP%.local" "%_UIPROP%"
	COPY /Y "%_UIINFO%.local" "%_UIINFO%"
	COPY /Y "%_UIUSERPROP%.local" "%_UIUSERPROP%"
) ELSE (
	"%_SEDEXE%" -ri.bak "s/#?(serviceHost=).*/\1%_SVCHOST%/" "%_UIPROP%"
	"%_SEDEXE%" -ri.bak "s/#?(servicePort=).*/\1%_SVCPORT%/" "%_UIPROP%"
	"%_SEDEXE%" -ri.bak "s/#?(servicePort=).*/\1%_SVCPORT%/" "%_UIUSERPROP%"
	"%_SEDEXE%" -ri.bak "s/([0-9]+),.*/\1,%_UIINFOGUID%/" "%_UIINFO%"
)

::Launch PuTTY
IF DEFINED _PUTTY (
	START "PuTTY" "C:\Program Files (x86)\PuTTY\putty.exe" -load "%_PUTTY%"
	ECHO Establish tunnel then
	PAUSE
)
START "CrashPlan" "%_DP0%\..\CrashPlanDesktop.exe"
