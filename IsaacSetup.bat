@echo off
setlocal enableextensions enabledelayedexpansion

REM =========================================================
REM Isaac Sim & Isaac Lab Fully Automatic Setup Script (Direct Extraction)
REM =========================================================
REM This script automates the full setup process:
REM 1. Creates necessary directory structure.
REM 2. Clones the Isaac Lab Git repository.
REM 3. Downloads the standalone Isaac Sim ZIP file.
REM 4. Extracts Isaac Sim's *contents* directly into Isaac Lab's '_isaac_sim' folder.
REM    This means the original top-level folder inside the ZIP is removed,
REM    and its contents (e.g., python.bat, exts folder) land directly in _isaac_sim.
REM 5. Cleans up only the downloaded ZIP file's directory.
REM
REM PRE-REQUISITES:
REM - Ensure 'curl' or 'wget' is available in your PATH for downloading.
REM - Ensure 'tar' is available in your PATH for extracting (built-in Windows 10/11).
REM - Ensure Git is installed and configured in your PATH.
REM
REM PLACE THIS SCRIPT INSIDE YOUR "Vex-RL-Auto" FOLDER.
REM =========================================================

echo.
echo =========================================================
echo  Starting Isaac Sim and Isaac Lab Full Repository Setup
echo =========================================================
echo.

REM --- Define Paths and URLs ---
set "SCRIPT_DIR_NO_TRAILING_SLASH=%~dp0"
if "%SCRIPT_DIR_NO_TRAILING_SLASH:~-1%"=="\" set "SCRIPT_DIR_NO_TRAILING_SLASH=%SCRIPT_DIR_NO_TRAILING_SLASH:~0,-1%"

for %%i in ("%SCRIPT_DIR_NO_TRAILING_SLASH%") do set "PARENT_DIR=%%~dpi"

set "ISAAC_SDK_ROOT=%PARENT_DIR%IsaacSDKs"
set "ISAAC_LAB_ROOT=%ISAAC_SDK_ROOT%\IsaacLab"
set "ISAAC_SIM_FINAL_LOCATION=%ISAAC_LAB_ROOT%\_isaac_sim"
set "ISAAC_SIM_DOWNLOAD_DIR=%ISAAC_SDK_ROOT%\Downloads"
set "ISAAC_SIM_ZIP_NAME=isaac-sim-standalone-4.5.0-rc.36.zip"
set "ISAAC_SIM_ZIP_URL=https://download.isaacsim.omniverse.nvidia.com/isaac-sim-standalone%%404.5.0-rc.36%%2Brelease.19112.f59b3005.gl.windows-x86_64.release.zip"


echo Setting up directories...
REM --- Pre-cleanup: Ensure a clean slate for all relevant directories ---
if exist "%ISAAC_SIM_DOWNLOAD_DIR%" rmdir /s /q "%ISAAC_SIM_DOWNLOAD_DIR%"
if exist "%ISAAC_SIM_FINAL_LOCATION%" rmdir /s /q "%ISAAC_SIM_FINAL_LOCATION%"

REM --- Create Base Directories ---
mkdir "%ISAAC_SDK_ROOT%" 2>nul
mkdir "%ISAAC_LAB_ROOT%" 2>nul
mkdir "%ISAAC_SIM_DOWNLOAD_DIR%" 2>nul
echo Directories ready.

echo.
echo Cloning Isaac Lab...
REM --- Clone Isaac Lab ---
if not exist "%ISAAC_LAB_ROOT%\.git" (
    cd /d "%ISAAC_LAB_ROOT%" || goto :error_cd_lab_dir_exit
    git clone https://github.com/isaac-sim/IsaacLab.git .
    if errorlevel 1 goto :error_git_clone_lab_exit
    echo Isaac Lab cloned successfully.
) else (
    echo Isaac Lab already exists, skipping clone.
)

echo.
echo Downloading Isaac Sim ZIP file... This may take a while (large file).
REM --- Download Isaac Sim ZIP ---
set "ZIP_PATH=%ISAAC_SIM_DOWNLOAD_DIR%\%ISAAC_SIM_ZIP_NAME%"
if not exist "%ZIP_PATH%" (
    cd /d "%ISAAC_SIM_DOWNLOAD_DIR%" || goto :error_cd_download_dir_exit
    curl -L -o "%ISAAC_SIM_ZIP_NAME%" "%ISAAC_SIM_ZIP_URL%"
    if errorlevel 0 (
        echo Isaac Sim ZIP downloaded with curl.
    ) else (
        echo Curl failed, trying wget...
        wget -O "%ISAAC_SIM_ZIP_NAME%" "%ISAAC_SIM_ZIP_URL%"
        if errorlevel 1 (
            echo [CRITICAL ERROR] Neither curl nor wget could download Isaac Sim ZIP.
            echo Please ensure curl or wget is installed and in your PATH, or download manually to "%ISAAC_SIM_DOWNLOAD_DIR%".
            goto :eof_fail
        ) else (
            echo Isaac Sim ZIP downloaded with wget.
        )
    )
) else (
    echo Isaac Sim ZIP already found, skipping download.
)

echo.
echo Extracting Isaac Sim contents directly into "%ISAAC_SIM_FINAL_LOCATION%"... This will also take some time.
REM --- Extract Isaac Sim Directly to Final Location ---
mkdir "%ISAAC_SIM_FINAL_LOCATION%" 2>nul || goto :error_create_dir_exit
cd /d "%ISAAC_SIM_FINAL_LOCATION%" || goto :error_cd_sim_final_dir_exit

REM Use --strip-components=1 to remove the top-level directory from the zip,
REM extracting its *contents* (e.g., bin, exts, kit, python.bat, isaac_sim.bat)
REM directly into _isaac_sim.
tar -xf "%ISAAC_SIM_DOWNLOAD_DIR%\%ISAAC_SIM_ZIP_NAME%"
if errorlevel 1 (
    echo [ERROR] Failed to extract Isaac Sim ZIP. Possible corrupted ZIP, insufficient disk space, or 'tar' issue.
    goto :eof_fail
)
echo Isaac Sim contents extracted successfully into _isaac_sim.

echo.
echo Cleaning up downloaded ZIP file...
REM --- Clean up Downloads ---
if exist "%ISAAC_SIM_DOWNLOAD_DIR%" (
    rmdir /s /q "%ISAAC_SIM_DOWNLOAD_DIR%"
    if errorlevel 1 (
        echo [WARNING] Failed to delete download directory. Please remove "%ISAAC_SIM_DOWNLOAD_DIR%" manually.
    ) else (
        echo Download directory cleaned.
    )
)

echo.
echo =========================================================
echo  All setup steps completed successfully! 🎉
echo =========================================================
echo.
exit /b 0

REM --- Error Handling ---
:error_create_dir_exit
echo [ERROR] Failed to create directory. Permissions issue or invalid path.
goto :eof_fail

:error_cd_download_dir_exit
echo [ERROR] Failed to change directory to download path.
goto :eof_fail

:error_cd_sim_final_dir_exit
echo [ERROR] Failed to change directory to Isaac Sim final location.
goto :eof_fail

:error_cd_lab_dir_exit
echo [ERROR] Failed to change directory to Isaac Lab clone path.
goto :eof_fail

:error_git_clone_lab_exit
echo [ERROR] Failed to clone Isaac Lab. Check internet, Git installation, or repository URL.
goto :eof_fail

:eof_fail
echo.
echo =========================================================
echo  Setup failed. Please review the error message(s) above. ❌
echo =========================================================
echo.
exit /b 1