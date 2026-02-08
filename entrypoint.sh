#!/bin/bash
set -e

# Function: print log message
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Function: install runtime dependencies
install_runtime_dependencies() {
    log "Checking and installing runtime dependencies..."

    local requirements_file="requirements.txt"
    local installed_packages_file="/tmp/installed_packages.txt"

    # If requirements.txt exists and is newer than installed packages list, reinstall
    if [ -f "$requirements_file" ]; then
        if [ ! -f "$installed_packages_file" ] || [ "$requirements_file" -nt "$installed_packages_file" ]; then
            log "New dependencies found, installing..."
            pip install --no-cache-dir -r "$requirements_file" 2>&1 | while read line; do
                log "pip: $line"
            done
            touch "$installed_packages_file"
            log "Dependencies installed"
        else
            log "Dependencies are up to date, skipping"
        fi
    else
        log "No requirements.txt found"
    fi
}

# Function: check requirements
check_requirements() {
    log "Checking application environment..."

    # Check configuration files if any
    log "Environment check completed"
}

# Function: start the application
start_app() {
    log "Starting pyVideoTrans..."

    # Parse command line arguments
    local cmd="sp.py"
    local args=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            --cli)
                cmd="cli.py"
                shift
                ;;
            --task)
                args="$args --task $2"
                shift 2
                ;;
            --name)
                args="$args --name \"$2\""
                shift 2
                ;;
            *)
                args="$args $1"
                shift
                ;;
        esac
    done

    log "Executing: python $cmd $args"
    exec python "$cmd" $args
}

# Main logic
log "pyVideoTrans Docker container starting..."

# Check environment
check_requirements

# Execute based on arguments
case "$1" in
    "web"|"")
        log "Starting GUI..."
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
