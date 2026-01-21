#!/bin/bash

# iVMS-4200 automated installation script
INSTALLER="/tmp/iVMS-4200(V3.5.0.9_E).exe"
INSTALL_MARKER="/config/.ivms_installed"
# Updated to the actual observed installation path
INSTALL_DIR="/config/.wine/drive_c/Program Files (x86)/iVMS-4200 Site"

echo "Checking iVMS-4200 installation status..."

# Check if already installed
if [ -f "$INSTALL_MARKER" ] && [ -d "$INSTALL_DIR" ]; then
    echo "iVMS-4200 is already installed."
else
    echo "Installing iVMS-4200 for the first time..."
    
    # Set environment variables
    export HOME=/config
    export WINEPREFIX="/config/.wine"
    export WINEARCH="win32"
    export WINEDEBUG="-all"
    export DISPLAY=:1

    # Initialize Wine prefix if needed
    if [ ! -d "$WINEPREFIX" ]; then
        echo "Initializing Wine prefix..."
        wineboot --init
        sleep 10
    fi

    # Install dependencies - adding more common ones for iVMS
    echo "Installing dependencies (mfc42, vcrun2008, vcrun2010)..."
    # mfc42 is usually enough, but vcrun often helps with initialization errors
    winetricks -q mfc42 vcrun2008 vcrun2010 || true
    sleep 5

    # Background task to auto-close error windows/dialogs
    (
        echo "Starting background window watcher..."
        for i in {1..200}; do
            # Find windows with "Error" or "fail" in title
            # This handles the "Npf service installation failed" dialog
            WINDOWS=$(xdotool search --name "iVMS-4200" 2>/dev/null || xdotool search --name "Error" 2>/dev/null || xdotool search --name "fail" 2>/dev/null)
            for WIN in $WINDOWS; do
                TITLE=$(xdotool getwindowname "$WIN" 2>/dev/null)
                echo "Found window: $TITLE ($WIN). Attempting to dismiss..."
                xdotool windowactivate "$WIN" 2>/dev/null
                xdotool key --window "$WIN" Return 2>/dev/null
                sleep 1
                xdotool windowclose "$WIN" 2>/dev/null
            done
            
            # Kill SPUpDateServer if it spawns
            pkill -f "SPUpDateServer.exe" || true
            
            sleep 3
        done
    ) &
    WATCHER_PID=$!

    # Run the installer
    echo "Running iVMS-4200 installer..."
    # Note: Using /S and letting it install to default Program Files (x86)
    wine "$INSTALLER" /S
    
    # Wait for installation to complete
    echo "Waiting for installer to finish..."
    
    MAX_WAIT=900 # 15 minutes
    WAIT_TIME=0
    # Wait for the main client binary or the framework binary
    while [ ! -f "$INSTALL_DIR/iVMS-4200 Client/Client/iVMS-4200.Framework.C.exe" ] && [ $WAIT_TIME -lt $MAX_WAIT ]; do
        sleep 15
        WAIT_TIME=$((WAIT_TIME + 15))
        echo "Installation in progress... ($WAIT_TIME seconds)"
    done

    # Clean up watcher
    kill "$WATCHER_PID" || true

    if [ -f "$INSTALL_DIR/iVMS-4200 Client/Client/iVMS-4200.Framework.C.exe" ]; then
        touch "$INSTALL_MARKER"
        echo "[$(date +'%T')] iVMS-4200 installation completed successfully!"
    else
        echo "[$(date +'%T')] ERROR: Installation failed or timed out. Executable not found at $INSTALL_DIR/iVMS-4200 Client/Client/iVMS-4200.Framework.C.exe"
        echo "[$(date +'%T')] Try checking the web interface to see if a manual action is required."
    fi
fi
