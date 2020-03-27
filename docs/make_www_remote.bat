@ECHO OFF

REM Assumes git is installed and that sphinx, sphinx_rtd_theme are installed in 
REM the _sphinx conda environment

SET LOCALDOC=_build
SET TEMPDOC=%TEMP%\\WecOptTool_sphinx_build

IF EXIST "%LOCALDOC%/" RMDIR /Q /S %LOCALDOC%
CALL activate _sphinx
sphinx-build -b html . %LOCALDOC%
CALL conda deactivate

FOR /F %%I IN ('git rev-parse --abbrev-ref HEAD') DO SET BRANCH=%%I

IF EXIST "%TEMPDOC%/" RMDIR /Q /S %TEMPDOC%
xcopy /E /F /I /Q /S %LOCALDOC% %TEMPDOC%

IF EXIST "gh-pages/" RMDIR /Q /S gh-pages
git worktree add gh-pages test_me
FOR /F "delims=" %%i IN ('DIR /B gh-pages') DO (
    RMDIR "gh-pages\\%%i" /S/Q || DEL "gh-pages\\%%i" /S/Q
)

CD gh-pages
xcopy /E /F /I /Q /S %TEMPDOC% .
COPY /Y NUL .nojekyll
ECHO "# WecOptTool Documenation" > README.md
git add --all
git commit -m "Publishing updated documentation..."
git push origin
CD ..

git worktree remove -f gh-pages
