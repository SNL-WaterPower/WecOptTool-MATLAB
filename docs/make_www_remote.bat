@ECHO OFF
setlocal ENABLEDELAYEDEXPANSION

REM make_www_remote <REMOTE> <BRANCH=gh-pages>
REM     Example: make_www_remote origin
REM     Example: make_www_remote public test-gh-pages
REM Assumes git is installed and that sphinx, sphinx_rtd_theme are installed in 
REM the _sphinx conda environment. The remote branch must already exist.

IF "%~1"=="" (
    GOTO signature
) ELSE (
    SET REMOTE=%~1
)

IF "%~2"=="" (
    SET BRANCH=gh-pages
) ELSE (
    SET BRANCH=%~2
)

SET LOCALDOC=_build
SET WORKTREE=_remote

IF EXIST "%LOCALDOC%/" RMDIR /Q /S %LOCALDOC%
CALL activate _sphinx
sphinx-build -W -b html . %LOCALDOC%
IF !ERRORLEVEL! GTR 0 GOTO sphinxerror
CALL conda deactivate

IF EXIST "%WORKTREE%/" RMDIR /Q /S %WORKTREE%
git worktree add --track -B %BRANCH% %WORKTREE% %REMOTE%/%BRANCH%
IF !ERRORLEVEL! GTR 0 GOTO brancherror

git --work-tree=%WORKTREE% pull
FOR /F "delims=" %%i IN ('DIR /B %WORKTREE%') DO (
    RMDIR "%WORKTREE%\\%%i" /S/Q 2> NUL || DEL "%WORKTREE%\\%%i" /S/Q
)
xcopy /E /F /I /Q /S %LOCALDOC% %WORKTREE%

CD %WORKTREE%
COPY /Y NUL .nojekyll
ECHO # WecOptTool Documentation > README.md
ECHO. >> README.md
git add --all
git commit -m "Publishing updated documentation..."
git push %REMOTE%
CD ..

RMDIR /Q /S %LOCALDOC%
git worktree remove -f %WORKTREE%
GOTO :EOF

:sphinxerror
CALL conda deactivate
ECHO.
ECHO ERROR: Sphinx docs failed to build
ECHO Consider running make_www_local.bat to debug
GOTO :EOF

:brancherror
ECHO.
ECHO git worktree add --track -B %BRANCH% %WORKTREE% %REMOTE%/%BRANCH%
ECHO.
ECHO ERROR: Unable to create worktree
ECHO Does the remote branch %REMOTE%/%BRANCH% exist^?
ECHO Is %BRANCH% already checked out^?
GOTO :EOF

:signature
ECHO make_www_remote ^<REMOTE^> ^<BRANCH=gh-pages^>
ECHO     Example: make_www_remote origin
ECHO     Example: make_www_remote public test-gh-pages
GOTO :EOF
