@ECHO OFF

REM Assumes git is installed and that sphinx, sphinx_rtd_theme are installed in 
REM the _sphinx conda environment

IF EXIST "_build/" RMDIR /Q /S _build
CALL activate _sphinx
sphinx-build -b html . _build
conda deactivate
