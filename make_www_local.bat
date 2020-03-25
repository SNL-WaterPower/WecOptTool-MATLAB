@ECHO OFF
setlocal ENABLEDELAYEDEXPANSION

REM Assumes git is installed and that sphinx, sphinx_rtd_theme are installed in 
REM the _sphinx conda environment

SET "GETGIT=true"

IF EXIST git_src ( 
    git --work-tree=git_src --git-dir=git_src/.git pull 2>&1 > NUL | findstr /C:"fatal"
    IF !ERRORLEVEL! GTR 0 SET "GETGIT="
)

IF DEFINED GETGIT (
    RMDIR /Q /S git_src
    git clone https://github.com/SNL-WaterPower/WecOptTool.git git_src
)

CALL activate _sphinx
sphinx-build -b html . _build
conda deactivate
