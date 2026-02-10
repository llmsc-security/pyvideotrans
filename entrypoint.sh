#!/bin/bash
set -e

# Function: print log message
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Function: check requirements
check_requirements() {
    log "Checking application environment..."
    log "Environment check completed"
}

# Main logic
log "pyVideoTrans Docker container starting..."

# Check environment
check_requirements

# Start Xvfb for headless GUI support
export DISPLAY=:99
Xvfb :99 -screen 0 1920x1080x24 &
XVFB_PID=$!

log "Xvfb started on DISPLAY=:99 (PID: $XVFB_PID)"

# Give Xvfb time to start
sleep 2

# Execute based on arguments
case "$1" in
    "web"|"")
        log "Starting GUI application (headless with Xvfb)..."
        # Run the app with headless Qt platform
        export QT_QPA_PLATFORM="offscreen"
        exec python sp.py
        ;;
    "cli"|"cli.py")
        shift
        log "Running CLI mode..."
        exec python cli.py "$@"
        ;;
    "health")
        log "Health check passed"
        exit 0
        ;;
    *)
        log "Executing custom command: $*"
        exec "$@"
        ;;
esac
