#!/usr/bin/env bash
set -e

echo "=========================================="
echo "  Kasm Workspaces Cleanup Script"
echo "=========================================="

echo "[INFO] Starting cleanup process..."

# Stop and remove Kasm containers
echo "[STEP 1/4] Stopping Kasm containers..."
if sudo docker ps -a | grep -q kasm; then
    sudo docker stop $(sudo docker ps -a -q --filter "name=kasm") 2>/dev/null || true
    echo "[INFO] Kasm containers stopped"
else
    echo "[INFO] No Kasm containers found running"
fi

# Remove Kasm containers (optional - commented out to preserve for inspection)
# echo "[STEP 2/4] Removing Kasm containers..."
# sudo docker rm $(sudo docker ps -a -q --filter "name=kasm") 2>/dev/null || true

# Clean up temporary files
echo "[STEP 2/4] Cleaning up temporary files..."
rm -f /tmp/kasm_install.log
rm -f /tmp/kasm_workspaces_*.tar.gz
echo "[INFO] Temporary files cleaned"

# Remove swap file if it was created
echo "[STEP 3/4] Checking swap configuration..."
if [ -f /swapfile ]; then
    echo "[INFO] Removing swap file created during installation..."
    sudo swapoff /swapfile 2>/dev/null || true
    sudo rm -f /swapfile
    echo "[INFO] Swap file removed"
else
    echo "[INFO] No custom swap file to remove"
fi

# Preserve logs and credentials for artifacts
echo "[STEP 4/4] Preserving logs and credentials..."
if [ -f /tmp/kasm_credentials.txt ]; then
    echo "[INFO] Kasm credentials preserved at /tmp/kasm_credentials.txt"
fi
if [ -f /tmp/lxd_registration.json ]; then
    echo "[INFO] LXD registration data preserved at /tmp/lxd_registration.json"
fi

echo ""
echo "=========================================="
echo "[SUCCESS] Cleanup completed!"
echo "=========================================="
echo ""
echo "Note: Kasm containers are stopped but not removed"
echo "      Logs and credentials are preserved for artifact collection"
