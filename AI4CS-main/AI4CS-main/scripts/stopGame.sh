#!/bin/bash

echo "=== Stopping CAI4EDUCATION ==="

# Stop bridges (Windows)
echo "[+] Killing bridge processes..."
/c/Windows/System32/taskkill.exe //F //T //IM "ssh_bridge_root.exe"
/c/Windows/System32/taskkill.exe //F //T //IM "ssh_bridge_server.exe"

# Stop Docker
echo "[+] Stopping Docker containers..."
cd "$(dirname "$0")/../docker"
docker compose down

echo "=== All stopped ==="