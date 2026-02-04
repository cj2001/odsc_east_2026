#!/bin/bash

# Auto-detect the Docker network based on directory name
DIR_NAME=$(basename "$PWD")
NETWORK_NAME="${DIR_NAME}_erkg-network"

echo "============================================"
echo "Initializing Senzing Database"
echo "============================================"
echo "Directory: $DIR_NAME"
echo "Network: $NETWORK_NAME"
echo ""

# Check if network exists
if ! docker network inspect "$NETWORK_NAME" >/dev/null 2>&1; then
    echo "❌ Error: Network '$NETWORK_NAME' not found!"
    echo ""
    echo "Make sure containers are running:"
    echo "  docker-compose up -d"
    echo ""
    exit 1
fi

# Check if database is already initialized
echo "Checking if database is already initialized..."
CHECK_RESULT=$(docker run --rm --network "$NETWORK_NAME" postgres:15 psql "postgresql://postgres:workshop@postgres:5432/erkg" -tAc "SELECT COUNT(*) FROM information_schema.tables WHERE table_name='sys_vars';" 2>/dev/null || echo "0")

if [ "$CHECK_RESULT" = "1" ]; then
    echo ""
    echo "============================================"
    echo "ℹ️  ALREADY INITIALIZED"
    echo "============================================"
    echo "Senzing database is already set up."
    echo "No action needed."
    echo ""
    echo "If you want to reset and start fresh:"
    echo "  docker-compose down -v"
    echo "  docker-compose up -d"
    echo "  ./scripts/init_database.sh"
    echo ""
    exit 0
fi

# Run initialization
echo "Database not initialized. Running setup..."
echo ""

docker run --rm --network "$NETWORK_NAME" --env SENZING_ENGINE_CONFIGURATION_JSON='{"PIPELINE":{"CONFIGPATH":"/etc/opt/senzing","RESOURCEPATH":"/opt/senzing/er/resources","SUPPORTPATH":"/opt/senzing/data"},"SQL":{"CONNECTION":"postgresql://postgres:workshop@postgres:5432:erkg?sslmode=disable"}}' senzing/init-database --install-senzing-er-configuration

# Check result
if [ $? -eq 0 ]; then
    echo ""
    echo "============================================"
    echo "✅ SUCCESS!"
    echo "============================================"
    echo "Senzing database initialized successfully."
    echo ""
    echo "Next steps:"
    echo "1. Open http://localhost:8888"
    echo "2. Run notebooks/00_setup_check.ipynb"
    echo ""
else
    echo ""
    echo "============================================"
    echo "❌ FAILED"
    echo "============================================"
    echo "Initialization failed. Check errors above."
    echo ""
    exit 1
fi