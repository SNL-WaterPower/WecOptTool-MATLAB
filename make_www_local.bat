@ECHO OFF

REM Assumes sphinx, sphinx_rtd_theme are installed in the _sphinx conda 
REM environment

CALL activate _sphinx
sphinx-build -b html . _build
conda deactivate
