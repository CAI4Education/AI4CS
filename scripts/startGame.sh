#!/bin/bash
set -e

echo "=== Starting CAI4EDUCATION Game ==="

# -------------------
# PATHS
# -------------------
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

BRIDGE_DIR="$ROOT_DIR/bridges/dist"
DOCKER_DIR="$ROOT_DIR/docker"
GAME_DIR="$ROOT_DIR/gameBuild"
LOG_DIR="$ROOT_DIR/logs"

mkdir -p "$LOG_DIR"

# -------------------
# CHECK DEPENDENCIES
# -------------------
command -v docker >/dev/null 2>&1 || {
  echo "[ERROR] Docker not installed."
  exit 1
}

command -v docker compose >/dev/null 2>&1 || {
  echo "[ERROR] docker-compose plugin not installed."
  exit 1
}

# -------------------
# START DOCKER
# -------------------
echo "[+] Starting Docker container..."
cd "$DOCKER_DIR"
docker compose up -d

sleep 3

# -------------------
# START BRIDGES (STANDALONE BINARIES)
# -------------------
echo "[+] Starting bridges..."

"$BRIDGE_DIR/ssh_bridge_server" \
  > "$LOG_DIR/terminal_bridge.log" 2>&1 &

TERM_BRIDGE_PID=$!

sleep 1

"$BRIDGE_DIR/ssh_bridge_root" \
  > "$LOG_DIR/root_bridge.log" 2>&1 &

ROOT_BRIDGE_PID=$!

sleep 2

# -------------------
# START GODOT
# -------------------
echo "[+] Starting Godot..."
cd "$GAME_DIR"
#./game.x86_64				#DECOMMENTA PER AVVIARE GIOCO + RINOMINA GIOCO

echo "[_] everything is booted"