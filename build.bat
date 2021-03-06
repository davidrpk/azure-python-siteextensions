@setlocal
@if "%~1" EQU "" goto usage

@set D=%~dp0
@if not defined OUTDIR set OUTDIR=%D%
@set NUGET="%D%Tools\nuget.exe"
@set CONTENT=%OUTDIR%\%~3\content\python%~3

%NUGET% install %1 -Version %2 -OutputDirectory "%OUTDIR%\source_packages"
@set PY="%OUTDIR%\source_packages\%~1.%~2\tools\python.exe"

@rem For older versions of Python, overwrite bdist_wininst to allow setuptools
@rem to execute its install_scripts command without crashing.
copy /Y "%D%Tools\distutils.command.bdist_wininst.py" "%OUTDIR%\source_packages\%~1.%~2\tools\Lib\distutils\command\bdist_wininst.py"

@rmdir /q /s "%CONTENT%" 2> nul
%PY% -m pip install -U pip setuptools certifi wfastcgi
%PY% "%D%Tools\copy_py.py" %3 "%CONTENT%\\"
@if errorlevel 1 exit /B
@if not exist "%OUTDIR%\Common" mkdir "%OUTDIR%\Common" && copy /Y "%D%Common\*" "%OUTDIR%\Common"
@if not exist "%OUTDIR%\%3\content\install.cmd" copy /Y "%D%%3\content\*" "%OUTDIR%\%3\content"
@if not exist "%OUTDIR%\packages" mkdir "%OUTDIR%\packages"
%NUGET% pack -NoPackageAnalysis "%D%%3\azureappservice-python%~3.nuspec" -OutputDirectory "%OUTDIR%\packages" -BasePath "%OUTDIR%\%3"
@if not errorlevel 1 rmdir /q /s "%CONTENT%"
@exit /B 0

:usage
@echo Usage: build.bat [package name] [package version] [version tag]
@echo.
@echo The package will be installed from Nuget and used to generate the site extension
@echo from itself.
@echo.
@echo Examples:
@echo.
@echo     build.bat python 3.6.4 364x64
@echo     build.bat python2x86 2.7.14 2714x86
@echo.
