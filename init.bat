@echo off
REM This script activates the portable Conda environment and opens a Command Prompt.

REM Get the directory where this script is located (e.g., D:\Projects\Robot\Vex-RL-Auto\)
set "PROJECT_ROOT=%~dp0"

REM Navigate to the python_scripts directory
cd /d "%PROJECT_ROOT%python_scripts"

REM Activate the vex_rl Conda environment
REM The 'call' command is crucial for batch scripts to continue after 'conda activate'.
call conda activate vex_rl

REM --- IMPORTANT: Error Check (optional but recommended) ---
REM This checks if the environment activation was successful.
REM %CONDA_PREFIX% is an environment variable set by 'conda activate'.
if not exist "%CONDA_PREFIX%\python.exe" (
    echo.
    echo ERROR: Failed to activate 'vex_rl' environment.
    echo Please ensure you have run "conda init cmd.exe" manually in a fresh CMD window,
    echo and that the 'vex_rl' environment has been created.
    echo Then close and reopen this script.
    echo.
    pause
    exit /b 1
)

REM Display a confirmation message
echo.
echo VEX-RL-Auto environment "vex_rl" is active.
echo You are in the python_scripts directory.
echo You can now run your Python scripts (e.g., python rl_agent_main.py).
echo.

REM Keep the Command Prompt window open
cmd /k