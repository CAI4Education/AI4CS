#!/bin/bash

# Setup environment
mkdir -p archive_room/sector_9/shelf_A/box_42
cd archive_room

# Create config file
echo "configuration=active" > system.conf

# Create hidden artifact
echo "ANCIENT_KNOWLEDGE" > sector_9/shelf_A/box_42/artifact.dat

# Create the locked verification script
cat << 'EOF' > repair_system.sh
#!/bin/bash

# Check Backup
if [[ ! -d "backup" ]]; then
    echo "[FAIL] Backup directory not found."
    exit 1
fi

if [[ ! -f "backup/system.conf" ]]; then
    echo "[FAIL] system.conf not found in backup."
    exit 1
fi

# Check Symbolic Link
if [[ ! -h "relic_link" ]]; then
    echo "[FAIL] 'relic_link' is missing or is not a symbolic link."
    exit 1
fi

# Check Link Target
TARGET=$(readlink -f relic_link)
if [[ "$TARGET" != *"sector_9/shelf_A/box_42/artifact.dat"* ]]; then
    echo "[FAIL] The link does not point to the correct artifact.dat file."
    exit 1
fi

echo "Archive Restored."
echo "FLAG: b0n3{hYp3rl1nk_t0_th3_p4st}"
EOF

# Lock the script (remove execution permissions)
chmod -x repair_system.sh

cd ..
echo "Challenge 19 initiated. Check the 'archive_room' folder."