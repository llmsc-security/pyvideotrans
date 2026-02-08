#!/bin/bash
# Invoke script for pyVideoTrans Docker container
# Usage: ./invoke.sh [mode] [options]

set -e

CONTAINER_NAME="pyvideotrans"
PORT=11160
IMAGE_NAME="pyvideotrans:latest"

# Parse arguments
MODE="${1:-web}"
shift || true

# Function to start the container
start_container() {
    echo "Starting pyVideoTrans container on port $PORT..."

    # Check if container already exists
    if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        echo "Container already exists, removing..."
        docker rm -f "$CONTAINER_NAME" || true
    fi

    # Run the container
    docker run -d \
        --name "$CONTAINER_NAME" \
        -p $PORT:8501 \
        -v "$(pwd)/videos:/app/videos:rw" \
        -v "$(pwd)/output:/app/output:rw" \
        -v "$(pwd)/models:/app/models:rw" \
        -e PYTHONUNBUFFERED=1 \
        --shm-size=2g \
        --restart=unless-stopped \
        "$IMAGE_NAME" \
        "$@"
}

# Function to stop the container
stop_container() {
    echo "Stopping pyVideoTrans container..."
    docker stop "$CONTAINER_NAME" || true
    docker rm -f "$CONTAINER_NAME" || true
}

# Function to show logs
show_logs() {
    docker logs -f "$CONTAINER_NAME"
}

# Function to run CLI command
run_cli() {
    local cli_args="$*"
    echo "Running CLI command: $cli_args"
    docker exec -it "$CONTAINER_NAME" python cli.py $cli_args
}

# Main logic
case "$MODE" in
    start)
        start_container
        echo "Container started successfully!"
        echo "Access the web UI at http://localhost:$PORT"
        ;;
    stop)
        stop_container
        echo "Container stopped successfully!"
        ;;
    logs)
        show_logs
        ;;
    cli)
        shift
        run_cli "$@"
        ;;
    health)
        docker exec "$CONTAINER_NAME" python -c "print('OK')" || echo "Container not running"
        ;;
    *)
        echo "Usage: $0 {start|stop|logs|cli <args>|health}"
        echo ""
        echo "Modes:"
        echo "  start    - Start the container in daemon mode"
        echo "  stop     - Stop and remove the container"
        echo "  logs     - Follow container logs"
        echo "  cli      - Run a CLI command inside the container"
        echo "  health   - Check container health"
        exit 1
        ;;
esac
