#!/usr/bin/env bash
set -e

echo "=========================================="
echo "  Kasm Workspaces Installation Script"
echo "=========================================="

# Configuration
KASM_VERSION="1.15.0"
KASM_PORT="443"
SWAP_SIZE="2048"

echo "[INFO] Starting Kasm Workspaces installation..."
echo "[INFO] Version: ${KASM_VERSION}"

# Check if running on Ubuntu
if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "[INFO] Detected OS: $NAME $VERSION"
fi

# Install dependencies
echo "[STEP 1/6] Installing dependencies..."
sudo apt-get update -qq
sudo apt-get install -y -qq curl wget jq

# Configure swap if needed
echo "[STEP 2/6] Checking swap configuration..."
if [ $(swapon --show | wc -l) -eq 0 ]; then
    echo "[INFO] No swap detected, creating ${SWAP_SIZE}MB swap file..."
    sudo fallocate -l ${SWAP_SIZE}M /swapfile || sudo dd if=/dev/zero of=/swapfile bs=1M count=${SWAP_SIZE}
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo "[INFO] Swap enabled successfully"
else
    echo "[INFO] Swap already configured"
fi

# Download Kasm Workspaces
echo "[STEP 3/6] Downloading Kasm Workspaces ${KASM_VERSION}..."
cd /tmp
KASM_TARBALL="kasm_workspaces_${KASM_VERSION}.tar.gz"
if [ ! -f "$KASM_TARBALL" ]; then
    wget -q https://kasm-static-content.s3.amazonaws.com/kasm_release_${KASM_VERSION}.tar.gz -O "$KASM_TARBALL"
    echo "[INFO] Download completed"
else
    echo "[INFO] Using cached tarball"
fi

# Extract and install
echo "[STEP 4/6] Extracting and preparing installation..."
tar -xzf "$KASM_TARBALL"
cd kasm_release

# Install Kasm
echo "[STEP 5/6] Installing Kasm Workspaces (this may take several minutes)..."
# Non-interactive installation with default passwords (for CI/CD)
sudo bash kasm_release/install.sh --accept-eula --swap-size ${SWAP_SIZE} -L ${KASM_PORT} 2>&1 | tee /tmp/kasm_install.log || {
    echo "[ERROR] Installation failed. Check logs at /tmp/kasm_install.log"
    exit 1
}

# Wait for services to start
echo "[STEP 6/6] Waiting for Kasm services to start..."
sleep 30

# Check if Kasm is running
echo "[INFO] Checking Kasm status..."
if sudo docker ps | grep -q kasm; then
    echo "[SUCCESS] Kasm containers are running"
    sudo docker ps --filter "name=kasm" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
else
    echo "[WARNING] Kasm containers may not be running properly"
fi

# Extract credentials from install log
echo ""
echo "=========================================="
echo "  Installation Complete!"
echo "=========================================="

if [ -f /tmp/kasm_install.log ]; then
    echo "[INFO] Extracting credentials from installation log..."
    
    # Try to extract user credentials
    KASM_USER=$(grep -oP "User: \K.*" /tmp/kasm_install.log | tail -1 || echo "admin@kasm.local")
    KASM_PASS=$(grep -oP "Password: \K.*" /tmp/kasm_install.log | tail -1 || echo "[Check installation log]")
    
    echo ""
    echo "Kasm Workspaces Access Information:"
    echo "  URL: https://localhost:${KASM_PORT}"
    echo "  API URL: https://localhost:${KASM_PORT}/api/public/swagger"
    echo "  Username: ${KASM_USER}"
    echo "  Password: ${KASM_PASS}"
    echo ""
    
    # Save credentials to file for later use
    cat > /tmp/kasm_credentials.txt <<EOF
KASM_URL=https://localhost:${KASM_PORT}
KASM_API_URL=https://localhost:${KASM_PORT}/api/public/swagger
KASM_USER=${KASM_USER}
KASM_PASSWORD=${KASM_PASS}
EOF
    
    echo "[INFO] Credentials saved to /tmp/kasm_credentials.txt"
fi

echo ""
echo "[SUCCESS] Kasm Workspaces installation completed!"
echo "=========================================="
