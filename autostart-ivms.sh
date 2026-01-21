#!/bin/bash

# Path to installation marker
INSTALL_MARKER="/config/.ivms_installed"
# Path to iVMS-4200 executable
IVMS_EXE="/config/.wine/drive_c/Program Files (x86)/iVMS-4200 Site/iVMS-4200 Client/Client/iVMS-4200.Framework.C.exe"

echo "[$(date +'%T')] Autostart script initiated."

# Function to start iVMS
start_ivms() {
    echo "[$(date +'%T')] Starting iVMS-4200..."
    cd "/config/.wine/drive_c/Program Files (x86)/iVMS-4200 Site/iVMS-4200 Client/Client" || exit
    wine "$IVMS_EXE" &
}

# Check if already installed
if [ -f "$INSTALL_MARKER" ] && [ -f "$IVMS_EXE" ]; then
    start_ivms
else
    echo "[$(date +'%T')] iVMS-4200 not found or installation marker missing."
    echo "[$(date +'%T')] Waiting for installation to complete..."
    
    # Wait for the marker file to appear (max 20 minutes)
    MAX_WAIT=1200
    WAIT_TIME=0
    while [ ! -f "$INSTALL_MARKER" ] && [ $WAIT_TIME -lt $MAX_WAIT ]; do
        sleep 10
        WAIT_TIME=$((WAIT_TIME + 10))
        if [ $((WAIT_TIME % 60)) -eq 0 ]; then
            echo "[$(date +'%T')] Still waiting for installation... ($WAIT_TIME seconds)"
        fi
        # Check if the exe appeared even if the marker didn't
        if [ -f "$IVMS_EXE" ]; then
            break
        fi
    done

    if [ -f "$IVMS_EXE" ]; then
        echo "[$(date +'%T')] Installation detected! Waiting a few more seconds for everything to settle..."
        sleep 10
        start_ivms
    else
        echo "[$(date +'%T')] ERROR: Installation failed or timed out. iVMS-4200 executable not found at: $IVMS_EXE"
    fi
fi
