#!/bin/bash
set -e

# Start pyVideoTrans GUI application (headless with Xvfb)
export DISPLAY=:99
export QT_QPA_PLATFORM="offscreen"

# Run the main application
exec python sp.py
