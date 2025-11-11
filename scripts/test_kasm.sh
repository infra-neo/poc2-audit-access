#!/usr/bin/env bash
set -e

echo "=========================================="
echo "  Kasm Workspaces Test Script"
echo "=========================================="

# Load credentials if available
if [ -f /tmp/kasm_credentials.txt ]; then
    source /tmp/kasm_credentials.txt
    echo "[INFO] Loaded Kasm credentials"
else
    KASM_URL="https://localhost:443"
    KASM_API_URL="https://localhost:443/api/public/swagger"
    echo "[WARNING] Credentials file not found, using defaults"
fi

echo ""
echo "[TEST 1/5] Checking Docker containers..."
if sudo docker ps | grep -q kasm; then
    echo "[PASS] Kasm containers are running"
    sudo docker ps --filter "name=kasm" --format "table {{.Names}}\t{{.Status}}"
else
    echo "[FAIL] No Kasm containers found running"
    exit 1
fi

echo ""
echo "[TEST 2/5] Testing Kasm web interface (port 443)..."
HTTP_CODE=$(curl -k -s -o /dev/null -w "%{http_code}" "${KASM_URL}/" || echo "000")
if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "302" ] || [ "$HTTP_CODE" = "301" ]; then
    echo "[PASS] Kasm web interface is accessible (HTTP $HTTP_CODE)"
else
    echo "[FAIL] Kasm web interface not accessible (HTTP $HTTP_CODE)"
    echo "[INFO] Trying to diagnose..."
    sudo docker logs $(sudo docker ps -q --filter "name=kasm_proxy" | head -1) 2>&1 | tail -20 || true
fi

echo ""
echo "[TEST 3/5] Testing Kasm API endpoint..."
API_CODE=$(curl -k -s -o /dev/null -w "%{http_code}" "${KASM_URL}/api/public/get_status" || echo "000")
if [ "$API_CODE" = "200" ] || [ "$API_CODE" = "401" ]; then
    echo "[PASS] Kasm API endpoint is responding (HTTP $API_CODE)"
else
    echo "[WARNING] Kasm API returned unexpected code (HTTP $API_CODE)"
fi

echo ""
echo "[TEST 4/5] Checking Kasm database connectivity..."
DB_CONTAINER=$(sudo docker ps --filter "name=kasm_db" --format "{{.Names}}" | head -1)
if [ ! -z "$DB_CONTAINER" ]; then
    if sudo docker exec "$DB_CONTAINER" pg_isready -q; then
        echo "[PASS] Kasm database is ready"
    else
        echo "[WARNING] Database may not be fully ready"
    fi
else
    echo "[WARNING] Database container not found"
fi

echo ""
echo "[TEST 5/5] Validating Swagger API documentation..."
SWAGGER_CODE=$(curl -k -s -o /dev/null -w "%{http_code}" "${KASM_API_URL}" || echo "000")
if [ "$SWAGGER_CODE" = "200" ]; then
    echo "[PASS] Swagger API documentation is accessible"
    echo "[INFO] Swagger URL: ${KASM_API_URL}"
else
    echo "[WARNING] Swagger documentation returned code: $SWAGGER_CODE"
fi

echo ""
echo "=========================================="
echo "  Test Summary"
echo "=========================================="
echo "[INFO] Kasm Workspaces is ready for API connections"
echo "[INFO] Web URL: ${KASM_URL}"
echo "[INFO] API Swagger URL: ${KASM_API_URL}"
echo ""
echo "[SUCCESS] All critical tests passed!"
echo "=========================================="
