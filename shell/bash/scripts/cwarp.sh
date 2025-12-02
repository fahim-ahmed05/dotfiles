#!/bin/bash

SERVICE="warp-svc.service"

# Check if warp-svc is active
if systemctl is-active --quiet "$SERVICE"; then
    echo "WARP daemon is running. Disconnecting..."
    sudo warp-cli disconnect
    echo "Stopping WARP service..."
    sudo systemctl stop "$SERVICE"
    echo "WARP is now disconnected and service stopped."
else
    echo "WARP daemon is not running. Starting..."
    sudo systemctl start "$SERVICE"

    # Wait briefly for the daemon to initialize
    sleep 2

    echo "Connecting WARP..."
    sudo warp-cli connect
    echo "WARP is now connected."
fi
