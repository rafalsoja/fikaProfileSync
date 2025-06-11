@echo off
setlocal enabledelayedexpansion

:: Change the game directory if needed
set "GAME_DIR=C:\GAMES\Escape From Tarkov"

set "URL1=http://172.22.89.147:6969"
set "URL2=http://172.22.59.102:6969"

set "RESPONDING=0"

curl --max-time 1 --silent --output nul "%URL1%/singleplayer/settings/version"
if !errorlevel! == 0 (
    echo [INFO] Server %URL1% is responding.
    set "RESPONDING=1"
    set "SELECTED_URL=%URL1%"
)

if "!RESPONDING!" == "0" (
    curl --max-time 1 --silent --output nul "%URL2%/singleplayer/settings/version"
    if !errorlevel! == 0 (
        echo [INFO] Server %URL2% is responding.
        set "RESPONDING=1"
        set "SELECTED_URL=%URL2%"
    )
)

if "!RESPONDING!" == "0" (
    echo [INFO] None of the servers are responding. Launching local server...


    echo [INFO] Profiles update...
    cd /d "!GAME_DIR!"
    git pull

    echo [INFO] Launching SPT.Server.exe
    SPT.Server.exe

    echo [INFO] Saving profile changes...

    git add BepInEx/plugins/*
    git add BepInEx/config/*
    git add user/profiles/*
    git add start.bat

    set "defaultMsg=Standard commit after server shutdown"
    set /p "commitMsg=Enter commit message (default: %defaultMsg%): "
    if "!commitMsg!" == "" (
        set "commitMsg=%defaultMsg%"
    )
    git commit -m "%commitMsg%"

    echo [INFO] Pushing changes to the repository...
    git push origin main
)

if "!RESPONDING!" == "1" (
    echo [INFO] Setting URL in config.json: !SELECTED_URL!

    > "!GAME_DIR!\user\launcher\config_tmp.json" (
        for /f "usebackq delims=" %%L in ("!GAME_DIR!\user\launcher\config.json") do (
            echo %%L | findstr /c:"\"Url\"" >nul
            if !errorlevel! == 0 (
                echo     "Url": "!SELECTED_URL!",
            ) else (
                echo %%L
            )
        )
    )

    move /Y "!GAME_DIR!\user\launcher\config_tmp.json" "!GAME_DIR!\user\launcher\config.json" >nul

    echo [INFO] Launching the game...
    start "" "!GAME_DIR!\SPT.Launcher.exe"
    exit /b 0
)