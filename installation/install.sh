#!/bin/bash
# ========================================================================
# Kernel Component - Installation Script (Linux/Mac)
# ========================================================================

set -e

echo "=========================================="
echo "  KERNEL COMPONENT INSTALLATION"
echo "  Version: 10.0.0.1"
echo "=========================================="
echo ""

# Step 1: Check prerequisites
echo "[1/6] Checking prerequisites..."
command -v java >/dev/null 2>&1 || { echo "Error: Java 17+ is required"; exit 1; }
command -v mvn >/dev/null 2>&1 || { echo "Error: Maven 3.9+ is required"; exit 1; }
echo "✓ Java and Maven found"

# Step 2: Build application
echo "[2/6] Building application..."
mvn clean package -DskipTests
echo "✓ Build completed"

# Step 3: Create directories
echo "[3/6] Creating directories..."
mkdir -p logs
mkdir -p config
echo "✓ Directories created"

# Step 4: Copy configuration files
echo "[4/6] Copying configuration..."
cp src/main/resources/application.yml config/
cp src/main/resources/application-dev.yml config/
echo "✓ Configuration copied"

# Step 5: Setup database (optional)
echo "[5/6] Database setup..."
read -p "Do you want to run Flyway migrations now? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    mvn flyway:migrate
    echo "✓ Database migrations completed"
else
    echo "⚠ Skipped database migrations"
fi

# Step 6: Final message
echo "[6/6] Installation complete!"
echo ""
echo "=========================================="
echo "  INSTALLATION SUCCESSFUL!"
echo "=========================================="
echo ""
echo "To start the application:"
echo "  ./scripts/start.sh"
echo ""
echo "To view logs:"
echo "  tail -f logs/kernel-component.log"
echo ""
echo "API will be available at:"
echo "  http://localhost:8083/api/v1/kernel"
echo ""

