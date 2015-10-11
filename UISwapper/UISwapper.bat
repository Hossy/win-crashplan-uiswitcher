@ECHO OFF
SETLOCAL
IF /I "%~1"=="" GOTO :EOF
::::Because Windows 8 "Run as administrator" doesn't respect the "Start in" shortcut option, we must CD to the directory the script is located.
::CD "%~dp0"

::Variables
SET _N0=%~n0
SET _DP0=%~dp0
SET _SEDEXE=%_DP0%sed.exe
::SET _UIPROP=%_DP0%..\conf\ui.properties
SET _UIINFO=%ProgramData%\CrashPlan\.ui_info
SET _UIUSERPROP=%ProgramData%\CrashPlan\conf\ui_%USERNAME%.properties
SET _IDENTITY=%ProgramData%\CrashPlan\.identity
SET _MYSVCXML=%ProgramData%\CrashPlan\conf\my.service.xml
SET _SVCHOST=127.0.0.1
SET _SVCPORT=4243

::Check for dependencies
IF NOT EXIST "%_SEDEXE%" ECHO Can't find sed.exe.  Aborting.& PAUSE & GOTO :EOF

::Process arguments
SET _PUTTY=
SET _UIINFOGUID=
SET _LOCAL=
:args_again
IF /I "%~1"=="/resetlocal" (
	CALL :resetlocal
	PAUSE
	GOTO :EOF
)
IF /I "%~1"=="/local" (
	SET _LOCAL=TRUE
	SHIFT
)
IF DEFINED _LOCAL IF /I NOT "%~1"=="" ECHO Cannot combine other options with /local.& PAUSE & GOTO :EOF
IF /I "%~1"=="/host" (
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

::Check for CrashPlan files
::IF NOT EXIST "%_UIPROP%" ECHO Can't find ui.properties file at "%_UIPROP%".  Aborting.& PAUSE & GOTO :EOF
IF NOT EXIST "%_UIINFO%" ECHO Can't find .ui_info file at "%_UIINFO%".  Aborting.& PAUSE & GOTO :EOF
IF NOT EXIST "%_UIUSERPROP%" ECHO Can't find ui_%USERNAME%.properties file at "%_UIUSERPROP%".  Aborting.& PAUSE & GOTO :EOF
IF NOT EXIST "%_IDENTITY%" ECHO Can't find .identity file at "%_IDENTITY%".  Aborting.& PAUSE & GOTO :EOF

::Check for local files
CALL :updatelocal

::Check .identity
> NUL FC /B "%_IDENTITY%" "%_IDENTITY%.local"
IF ERRORLEVEL 1 (
	ECHO .identity file has changed.  Inspecting further...
	> "%_IDENTITY%.inspect-current" FINDSTR /B /V /C:# "%_IDENTITY%"
	> "%_IDENTITY%.inspect-local" FINDSTR /B /V /C:# "%_IDENTITY%.local"
	> NUL FC /B "%_IDENTITY%.inspect-current" "%_IDENTITY%.inspect-local"
	IF ERRORLEVEL 1 (
		ECHO .identity file has changed.  Aborting.
		ECHO Check all data files and run %_N0% /resetlocal to reset.
		PAUSE
		REM START "ProgramFiles-conf" "%_DP0%..\conf"
		START "ProgramData" "%ProgramData%\CrashPlan"
		START "ProgramData-conf" "%ProgramData%\CrashPlan\conf"
		GOTO :EOF
	) ELSE (
		ECHO Changes in .identity file were insignificant.  Resetting local files...
		TIMEOUT /T 10
		COPY /Y "%_IDENTITY%" "%_IDENTITY%.local"
		COPY /Y "%_UIUSERPROP%" "%_UIUSERPROP%.local"
	)
	ERASE /Q "%_IDENTITY%.inspect-current"
	ERASE /Q "%_IDENTITY%.inspect-local"
)

::Check .ui_info.local
::ASSERT: .ui_info.local exists
FOR /F "usebackq tokens=*" %%A IN (`START /B "sed" "%_SEDEXE%" -nr "s/^[ \t]*<installVersion>(.*?)<\/installVersion>/\1/p" "%_MYSVCXML%"`) DO SET _XMLVER=%%A
FOR /F "usebackq tokens=*" %%A IN (`START /B "sed" "%_SEDEXE%" -nr "s/^[ \t]*<servicePort>(.*?)<\/servicePort>/\1/p" "%_MYSVCXML%"`) DO SET _XMLSVCPORT=%%A
FOR /F "usebackq tokens=*" %%A IN (`START /B "sed" "%_SEDEXE%" -nr "s/^([0-9]+),(.*)/\1/p" "%_UIINFO%.local"`) DO SET _UIINFOLCLPORT=%%A
IF /I NOT "%_UIINFOLCLPORT%"=="%_XMLSVCPORT%" (
	ECHO Local CrashPlan instance has moved ports.  Need to update .local files before
	ECHO proceeding.
	TIMEOUT /T 10
	CALL :resetlocal
	CALL :fixcpbug
	CALL :updatelocal
)

::Close CrashPlanDesktop (UI)
TASKKILL /F /IM CrashPlanDesktop.exe /T

::Update UI files
IF DEFINED _LOCAL (
	REM COPY /Y "%_UIPROP%.local" "%_UIPROP%"
	COPY /Y "%_UIINFO%.local" "%_UIINFO%"
	COPY /Y "%_UIUSERPROP%.local" "%_UIUSERPROP%"
) ELSE (
	REM "%_SEDEXE%" -ri.bak "s/^#?(serviceHost=).*/\1%_SVCHOST%/" "%_UIPROP%"
	REM "%_SEDEXE%" -ri.bak "s/^#?(servicePort=).*/\1%_SVCPORT%/" "%_UIPROP%"
	"%_SEDEXE%" -ri.bak "s/^#?(servicePort=).*/\1%_SVCPORT%/" "%_UIUSERPROP%"
	"%_SEDEXE%" -ri.bak "s/^[0-9]+,.*?,.*/%_SVCPORT%,%_UIINFOGUID%,%_SVCHOST%/" "%_UIINFO%"
)

::Launch PuTTY
IF DEFINED _PUTTY (
	START "PuTTY" "C:\Program Files (x86)\PuTTY\putty.exe" -load "%_PUTTY%"
	ECHO Establish tunnel then
	PAUSE
)
START "CrashPlan" "%_DP0%\..\CrashPlanDesktop.exe"

GOTO :EOF

:resetlocal
ECHO Deleting local files...
::IF EXIST "%_UIPROP%.local" ERASE /Q "%_UIPROP%.local"
IF EXIST "%_UIINFO%.local" ERASE /Q "%_UIINFO%.local"
IF EXIST "%_UIUSERPROP%.local" ERASE /Q "%_UIUSERPROP%.local"
IF EXIST "%_IDENTITY%.local" ERASE /Q "%_IDENTITY%.local"
ECHO Deleting .bak files...
::IF EXIST "%_UIPROP%.bak" ERASE /Q "%_UIPROP%.bak"
IF EXIST "%_UIINFO%.bak" ERASE /Q "%_UIINFO%.bak"
IF EXIST "%_UIUSERPROP%.bak" ERASE /Q "%_UIUSERPROP%.bak"
IF EXIST "%_IDENTITY%.bak" ERASE /Q "%_IDENTITY%.bak"
GOTO :EOF

:updatelocal
::IF NOT EXIST "%_UIPROP%.local" COPY "%_UIPROP%" "%_UIPROP%.local"
IF NOT EXIST "%_UIINFO%.local" COPY "%_UIINFO%" "%_UIINFO%.local"
IF NOT EXIST "%_UIUSERPROP%.local" COPY "%_UIUSERPROP%" "%_UIUSERPROP%.local"
IF NOT EXIST "%_IDENTITY%.local" COPY "%_IDENTITY%" "%_IDENTITY%.local"
GOTO :EOF

:fixcpbug
SET _FIXCPBUG=
IF /I "%_XMLVER%"=="1427864410430" SET _FIXCPBUG=TRUE
IF /I "%_XMLVER%"=="1435726800441" SET _FIXCPBUG=TRUE
IF NOT DEFINED _FIXCPBUG GOTO :EOF
::CrashPlan 4.3.0 fails to update the ui_%USERNAME%.properties file with the new servicePort upon port change.
ECHO Fixing CrashPlan bug with %_UIUSERPROP%
"%_SEDEXE%" -ri.bak "s/^#?(servicePort=).*/\1%_XMLSVCPORT%/" "%_UIUSERPROP%"
GOTO :EOF
