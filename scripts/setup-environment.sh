#!/bin/bash
# ========================================================================
# Kernel Component - Environment Setup Script (Linux/Mac)
# ========================================================================

echo "========================================"
echo "  KERNEL COMPONENT - ENVIRONMENT SETUP"
echo "========================================"
echo ""

# Detect shell configuration file
if [ -f "$HOME/.zshrc" ]; then
    SHELL_RC="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
    SHELL_RC="$HOME/.bashrc"
else
    SHELL_RC="$HOME/.bash_profile"
fi

echo "Using shell configuration: $SHELL_RC"
echo ""

# Step 1: Detect Java Installation
echo "[1/4] Detecting Java installation..."

JAVA_LOCATIONS=(
    "/usr/lib/jvm/java-17-openjdk"
    "/usr/lib/jvm/java-17-openjdk-amd64"
    "/Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home"
    "/usr/lib/jvm/jdk-17"
)

JAVA_HOME_FOUND=""
for location in "${JAVA_LOCATIONS[@]}"; do
    if [ -d "$location" ]; then
        JAVA_HOME_FOUND="$location"
        break
    fi
done

if [ -n "$JAVA_HOME_FOUND" ]; then
    echo "✓ Java found at: $JAVA_HOME_FOUND"
    
    # Add to shell configuration if not already present
    if ! grep -q "export JAVA_HOME=" "$SHELL_RC"; then
        echo "" >> "$SHELL_RC"
        echo "# Java Configuration" >> "$SHELL_RC"
        echo "export JAVA_HOME=$JAVA_HOME_FOUND" >> "$SHELL_RC"
        echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> "$SHELL_RC"
        echo "✓ JAVA_HOME added to $SHELL_RC"
    else
        echo "✓ JAVA_HOME already configured"
    fi
    
    # Set for current session
    export JAVA_HOME="$JAVA_HOME_FOUND"
    export PATH="$JAVA_HOME/bin:$PATH"
else
    echo "✗ Java 17 not found"
    echo "  Install Java 17:"
    echo "  - Ubuntu: sudo apt install openjdk-17-jdk"
    echo "  - macOS: brew install openjdk@17"
    exit 1
fi

# Step 2: Detect Maven Installation
echo ""
echo "[2/4] Detecting Maven installation..."

MAVEN_LOCATIONS=(
    "/opt/maven"
    "/usr/share/maven"
    "/usr/local/maven"
    "$HOME/.m2/wrapper/dists/apache-maven-3.9.6"
)

MAVEN_HOME_FOUND=""
for location in "${MAVEN_LOCATIONS[@]}"; do
    if [ -f "$location/bin/mvn" ]; then
        MAVEN_HOME_FOUND="$location"
        break
    fi
done

if [ -n "$MAVEN_HOME_FOUND" ]; then
    echo "✓ Maven found at: $MAVEN_HOME_FOUND"
    
    # Add to shell configuration if not already present
    if ! grep -q "export MAVEN_HOME=" "$SHELL_RC"; then
        echo "" >> "$SHELL_RC"
        echo "# Maven Configuration" >> "$SHELL_RC"
        echo "export MAVEN_HOME=$MAVEN_HOME_FOUND" >> "$SHELL_RC"
        echo "export PATH=\$MAVEN_HOME/bin:\$PATH" >> "$SHELL_RC"
        echo "✓ MAVEN_HOME added to $SHELL_RC"
    else
        echo "✓ MAVEN_HOME already configured"
    fi
    
    # Set for current session
    export MAVEN_HOME="$MAVEN_HOME_FOUND"
    export PATH="$MAVEN_HOME/bin:$PATH"
else
    echo "⚠️  Maven not found"
    echo "  You can use Maven Wrapper (./mvnw) instead"
    echo "  Or install Maven:"
    echo "  - Ubuntu: sudo apt install maven"
    echo "  - macOS: brew install maven"
fi

# Step 3: Verify Installation
echo ""
echo "[3/4] Verifying installation..."

if command -v java &> /dev/null; then
    JAVA_VER=$(java -version 2>&1 | head -n 1)
    echo "✓ Java: $JAVA_VER"
else
    echo "✗ Java verification failed"
fi

if command -v mvn &> /dev/null; then
    MAVEN_VER=$(mvn -version 2>&1 | head -n 1)
    echo "✓ Maven: $MAVEN_VER"
else
    echo "⚠️  Maven not available (use ./mvnw)"
fi

# Step 4: Summary
echo ""
echo "========================================"
echo "  SETUP COMPLETE!"
echo "========================================"
echo ""
echo "Environment variables added to: $SHELL_RC"
echo ""
echo "Next Steps:"
echo "1. Reload shell configuration:"
echo "   source $SHELL_RC"
echo ""
echo "2. Navigate to kernel-component directory"
echo ""
echo "3. Build the project:"
echo "   mvn clean package"
echo ""
echo "Environment Variables Set:"
echo "  JAVA_HOME  = $JAVA_HOME"
if [ -n "$MAVEN_HOME_FOUND" ]; then
    echo "  MAVEN_HOME = $MAVEN_HOME"
fi
echo ""

