#!/bin/bash

# Build Verification Script
# Tests if AAPT2 binaries were built correctly and work as expected

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/build"
TEST_DIR="$SCRIPT_DIR/test-verification"

echo "======================================"
echo "AAPT2 Build Verification Script"
echo "======================================"
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    if [ "$1" = "SUCCESS" ]; then
        echo -e "${GREEN}✓ $2${NC}"
    elif [ "$1" = "FAIL" ]; then
        echo -e "${RED}✗ $2${NC}"
    elif [ "$1" = "WARN" ]; then
        echo -e "${YELLOW}⚠ $2${NC}"
    else
        echo "  $2"
    fi
}

# Check if binaries exist
check_binaries() {
    echo "1. Checking for built binaries..."
    echo ""
    
    local all_exist=true
    
    for binary in aapt2 aapt2_64 aapt aapt_64; do
        if [ -f "$BUILD_DIR/$binary" ]; then
            size=$(ls -lh "$BUILD_DIR/$binary" | awk '{print $5}')
            print_status "SUCCESS" "$binary exists ($size)"
        else
            print_status "FAIL" "$binary not found"
            all_exist=false
        fi
    done
    
    echo ""
    return $([ "$all_exist" = true ] && echo 0 || echo 1)
}

# Check if binaries are executable
check_executable() {
    echo "2. Checking if binaries are executable..."
    echo ""
    
    local all_executable=true
    
    for binary in aapt2 aapt2_64 aapt aapt_64; do
        if [ -f "$BUILD_DIR/$binary" ]; then
            if [ -x "$BUILD_DIR/$binary" ]; then
                print_status "SUCCESS" "$binary is executable"
            else
                print_status "FAIL" "$binary is not executable"
                chmod +x "$BUILD_DIR/$binary" 2>/dev/null && \
                    print_status "SUCCESS" "Fixed: made $binary executable"
                all_executable=false
            fi
        fi
    done
    
    echo ""
    return $([ "$all_executable" = true ] && echo 0 || echo 1)
}

# Test AAPT2 version command
test_version() {
    echo "3. Testing version commands..."
    echo ""
    
    if [ -f "$BUILD_DIR/aapt2" ]; then
        if output=$("$BUILD_DIR/aapt2" version 2>&1); then
            print_status "SUCCESS" "aapt2 version: $output"
        else
            print_status "FAIL" "aapt2 version command failed"
            return 1
        fi
    fi
    
    if [ -f "$BUILD_DIR/aapt" ]; then
        if output=$("$BUILD_DIR/aapt" version 2>&1); then
            print_status "SUCCESS" "aapt version: $output"
        else
            print_status "WARN" "aapt version command failed (may be expected)"
        fi
    fi
    
    echo ""
}

# Test library dependencies
check_dependencies() {
    echo "4. Checking library dependencies..."
    echo ""
    
    if command -v ldd &> /dev/null; then
        if [ -f "$BUILD_DIR/aapt2" ]; then
            echo "Dependencies for aapt2:"
            if ldd "$BUILD_DIR/aapt2" | grep "not found"; then
                print_status "FAIL" "Missing library dependencies"
                return 1
            else
                print_status "SUCCESS" "All dependencies satisfied"
            fi
        fi
    elif command -v otool &> /dev/null; then
        # macOS
        if [ -f "$BUILD_DIR/aapt2" ]; then
            echo "Dependencies for aapt2:"
            otool -L "$BUILD_DIR/aapt2" | head -10
            print_status "SUCCESS" "Checked dependencies (macOS)"
        fi
    else
        print_status "WARN" "Cannot check dependencies (ldd/otool not available)"
    fi
    
    echo ""
}

# Test basic functionality
test_functionality() {
    echo "5. Testing basic functionality..."
    echo ""
    
    # Create test directory
    rm -rf "$TEST_DIR"
    mkdir -p "$TEST_DIR/res/values"
    
    # Create a simple XML resource
    cat > "$TEST_DIR/res/values/strings.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">TestApp</string>
    <string name="hello">Hello World</string>
</resources>
EOF
    
    if [ -f "$BUILD_DIR/aapt2" ]; then
        # Test compile
        if "$BUILD_DIR/aapt2" compile -o "$TEST_DIR/compiled.zip" "$TEST_DIR/res/values/strings.xml" 2>&1; then
            print_status "SUCCESS" "aapt2 compile command works"
            
            # Test dump if compile succeeded
            if [ -f "$TEST_DIR/compiled.zip" ]; then
                if "$BUILD_DIR/aapt2" dump "$TEST_DIR/compiled.zip" &>/dev/null; then
                    print_status "SUCCESS" "aapt2 dump command works"
                else
                    print_status "WARN" "aapt2 dump command failed"
                fi
            fi
        else
            print_status "FAIL" "aapt2 compile command failed"
            return 1
        fi
    else
        print_status "WARN" "aapt2 not found, skipping functionality test"
    fi
    
    # Cleanup
    rm -rf "$TEST_DIR"
    echo ""
}

# Check file type and architecture
check_architecture() {
    echo "6. Checking binary architecture..."
    echo ""
    
    if command -v file &> /dev/null; then
        for binary in aapt2 aapt2_64; do
            if [ -f "$BUILD_DIR/$binary" ]; then
                info=$(file "$BUILD_DIR/$binary")
                print_status "INFO" "$binary: $info"
            fi
        done
    else
        print_status "WARN" "file command not available"
    fi
    
    echo ""
}

# Generate report
generate_report() {
    echo "======================================"
    echo "Verification Summary"
    echo "======================================"
    echo ""
    
    echo "Build directory: $BUILD_DIR"
    echo "Test directory: $TEST_DIR (temporary)"
    echo ""
    
    if [ $TOTAL_ERRORS -eq 0 ]; then
        print_status "SUCCESS" "All verifications passed!"
        echo ""
        echo "Your AAPT2 binaries are ready to use."
        echo ""
        echo "Next steps:"
        echo "  - Test with real Android projects"
        echo "  - Install system-wide: sudo make install"
        echo "  - Read usage examples: cat README.md"
    else
        print_status "FAIL" "Found $TOTAL_ERRORS error(s) during verification"
        echo ""
        echo "Please review the errors above and:"
        echo "  - Check build logs for compilation errors"
        echo "  - Ensure all dependencies are installed"
        echo "  - Try rebuilding: make clean && make all"
        echo "  - See INSTALL.md for troubleshooting"
    fi
    
    echo ""
}

# Main execution
main() {
    TOTAL_ERRORS=0
    
    # Run all checks
    check_binaries || TOTAL_ERRORS=$((TOTAL_ERRORS + 1))
    check_executable || TOTAL_ERRORS=$((TOTAL_ERRORS + 1))
    test_version || TOTAL_ERRORS=$((TOTAL_ERRORS + 1))
    check_dependencies || TOTAL_ERRORS=$((TOTAL_ERRORS + 1))
    test_functionality || TOTAL_ERRORS=$((TOTAL_ERRORS + 1))
    check_architecture
    
    # Generate final report
    generate_report
    
    # Exit with error code if any check failed
    exit $TOTAL_ERRORS
}

# Run main
main
