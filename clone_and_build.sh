#!/bin/bash
set -e

# Script to clone only necessary files from Android source and build AAPT2
# This script clones from android.googlesource.com/platform/frameworks/base
# Tag: android-16.0.0_r4

REPO_URL="https://android.googlesource.com/platform/frameworks/base"
SYSTEM_CORE_URL="https://android.googlesource.com/platform/system/core"
TAG="android-16.0.0_r4"
WORK_DIR=$(pwd)

echo "==================================="
echo "AAPT2 Clone and Build Script"
echo "==================================="
echo "Repository: $REPO_URL"
echo "Tag: $TAG"
echo "Working Directory: $WORK_DIR"
echo "==================================="

# Function to clone with sparse checkout
clone_sparse() {
    echo "Step 1: Initializing frameworks-base repository..."
    if [ -d "frameworks-base" ]; then
        echo "Removing existing frameworks-base directory..."
        rm -rf frameworks-base
    fi
    
    mkdir -p frameworks-base
    cd frameworks-base
    
    git init
    git remote add origin $REPO_URL
    
    echo "Step 2: Configuring sparse checkout for frameworks-base..."
    git config core.sparseCheckout true
    
    # Define sparse checkout paths for AAPT2
    cat > .git/info/sparse-checkout << EOF
# AAPT2 source files
/tools/aapt2/
/tools/aapt/

# Build files
Android.bp
Android.mk

# Headers and includes that AAPT2 might need
/libs/androidfw/
/include/androidfw/
/core/res/

# Proto definitions if needed
/tools/aapt2/proto/
EOF
    
    echo "Step 3: Fetching refs/tags/$TAG from frameworks-base (this may take a while)..."
    git fetch --depth 1 origin refs/tags/$TAG:refs/tags/$TAG
    
    echo "Step 4: Checking out tag $TAG..."
    git checkout $TAG
    
    echo "frameworks-base clone completed successfully!"
    cd "$WORK_DIR"
    
    echo ""
    echo "Step 5: Initializing system-core repository..."
    if [ -d "system-core" ]; then
        echo "Removing existing system-core directory..."
        rm -rf system-core
    fi
    
    mkdir -p system-core
    cd system-core
    
    git init
    git remote add origin $SYSTEM_CORE_URL
    
    echo "Step 6: Configuring sparse checkout for system-core..."
    git config core.sparseCheckout true
    
    # Define sparse checkout paths for android-base headers
    cat > .git/info/sparse-checkout << EOF
# Android base library headers
/base/include/
EOF
    
    echo "Step 7: Fetching refs/tags/$TAG from system-core (this may take a while)..."
    git fetch --depth 1 origin refs/tags/$TAG:refs/tags/$TAG
    
    echo "Step 8: Checking out tag $TAG..."
    git checkout $TAG
    
    echo "system-core clone completed successfully!"
    cd "$WORK_DIR"
}

# Function to check build dependencies
check_dependencies() {
    echo "==================================="
    echo "Checking build dependencies..."
    echo "==================================="
    
    MISSING_DEPS=()
    
    # Check for essential build tools
    if ! command -v cmake &> /dev/null; then
        MISSING_DEPS+=("cmake")
    fi
    
    if ! command -v ninja &> /dev/null; then
        MISSING_DEPS+=("ninja-build")
    fi
    
    if ! command -v g++ &> /dev/null; then
        MISSING_DEPS+=("g++")
    fi
    
    if ! command -v protoc &> /dev/null; then
        MISSING_DEPS+=("protobuf-compiler")
    fi
    
    # Check for required libraries
    if ! ldconfig -p | grep -q libz.so; then
        MISSING_DEPS+=("zlib1g-dev")
    fi
    
    if ! ldconfig -p | grep -q libprotobuf.so; then
        MISSING_DEPS+=("libprotobuf-dev")
    fi
    
    if [ ${#MISSING_DEPS[@]} -ne 0 ]; then
        echo "ERROR: Missing dependencies: ${MISSING_DEPS[*]}"
        echo ""
        echo "On Ubuntu/Debian, install with:"
        echo "sudo apt-get update"
        echo "sudo apt-get install -y ${MISSING_DEPS[*]} build-essential pkg-config libexpat1-dev libpng-dev"
        echo ""
        echo "On macOS, install with:"
        echo "brew install ${MISSING_DEPS[*]} expat libpng"
        return 1
    fi
    
    echo "All dependencies are satisfied!"
}

# Function to build AAPT2
build_aapt2() {
    echo "==================================="
    echo "Building AAPT2 binaries..."
    echo "==================================="
    
    cd "$WORK_DIR"
    
    # Create build directory
    mkdir -p build
    cd build
    
    # Note: Building AAPT2 from Android source typically requires
    # the full Android build system (Soong/Blueprint)
    # This is a simplified approach that may need adjustments
    
    echo "Creating CMakeLists.txt for AAPT2..."
    
    cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.10)
project(aapt2)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find required packages
find_package(Protobuf REQUIRED)
find_package(ZLIB REQUIRED)
find_package(PNG REQUIRED)
find_package(EXPAT REQUIRED)

# Include directories
include_directories(
    ${CMAKE_SOURCE_DIR}/../frameworks-base/tools/aapt2
    ${CMAKE_SOURCE_DIR}/../frameworks-base/tools/aapt2/include
    ${CMAKE_SOURCE_DIR}/../frameworks-base/libs/androidfw/include
    ${CMAKE_SOURCE_DIR}/../frameworks-base/include
    ${CMAKE_SOURCE_DIR}/../system-core/base/include
    ${PROTOBUF_INCLUDE_DIRS}
)

# Collect AAPT2 source files
file(GLOB_RECURSE AAPT2_SOURCES 
    "${CMAKE_SOURCE_DIR}/../frameworks-base/tools/aapt2/*.cpp"
)

# Remove test files
list(FILTER AAPT2_SOURCES EXCLUDE REGEX ".*_test\\.cpp$")
list(FILTER AAPT2_SOURCES EXCLUDE REGEX ".*/tests/.*")

# Build AAPT2 executable
add_executable(aapt2 ${AAPT2_SOURCES})
target_link_libraries(aapt2 
    ${PROTOBUF_LIBRARIES}
    ${ZLIB_LIBRARIES}
    PNG::PNG
    ${EXPAT_LIBRARIES}
    pthread
)

# Build 64-bit version explicitly
add_executable(aapt2_64 ${AAPT2_SOURCES})
set_target_properties(aapt2_64 PROPERTIES COMPILE_FLAGS "-m64")
target_link_libraries(aapt2_64 
    ${PROTOBUF_LIBRARIES}
    ${ZLIB_LIBRARIES}
    PNG::PNG
    ${EXPAT_LIBRARIES}
    pthread
)

# Note: AAPT (version 1) source files
file(GLOB_RECURSE AAPT_SOURCES 
    "${CMAKE_SOURCE_DIR}/../frameworks-base/tools/aapt/*.cpp"
)

# Remove test files
list(FILTER AAPT_SOURCES EXCLUDE REGEX ".*_test\\.cpp$")
list(FILTER AAPT_SOURCES EXCLUDE REGEX ".*/tests/.*")

# Build AAPT executable
if(AAPT_SOURCES)
    add_executable(aapt ${AAPT_SOURCES})
    target_link_libraries(aapt 
        ${ZLIB_LIBRARIES}
        PNG::PNG
        ${EXPAT_LIBRARIES}
        pthread
    )
    
    # Build 64-bit version
    add_executable(aapt_64 ${AAPT_SOURCES})
    set_target_properties(aapt_64 PROPERTIES COMPILE_FLAGS "-m64")
    target_link_libraries(aapt_64 
        ${ZLIB_LIBRARIES}
        PNG::PNG
        ${EXPAT_LIBRARIES}
        pthread
    )
endif()
EOF
    
    echo "Configuring build with CMake..."
    cmake -G "Unix Makefiles" .
    
    echo "Building binaries..."
    make -j$(nproc)
    
    echo ""
    echo "==================================="
    echo "Build completed!"
    echo "==================================="
    echo "Binaries created:"
    ls -lh aapt* 2>/dev/null || echo "Warning: Some binaries may not have been built"
    
    cd "$WORK_DIR"
}

# Main execution
main() {
    echo "Starting AAPT2 clone and build process..."
    echo ""
    
    # Step 1: Clone repository with sparse checkout
    clone_sparse
    
    # Step 2: Check dependencies
    if ! check_dependencies; then
        echo ""
        echo "Please install missing dependencies and run this script again."
        exit 1
    fi
    
    # Step 3: Build AAPT2
    build_aapt2
    
    echo ""
    echo "==================================="
    echo "Process completed successfully!"
    echo "==================================="
    echo ""
    echo "Built binaries are located in: $WORK_DIR/build/"
    echo ""
    echo "You can copy them to a system directory with:"
    echo "  sudo cp build/aapt2 /usr/local/bin/"
    echo "  sudo cp build/aapt2_64 /usr/local/bin/"
    echo "  sudo cp build/aapt /usr/local/bin/"
    echo "  sudo cp build/aapt_64 /usr/local/bin/"
}

# Run main function
main
