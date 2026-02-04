#!/bin/bash
set -e

# Script to clone only necessary files from Android source and build AAPT2
# This script clones from android.googlesource.com/platform/frameworks/base
# Tag: android-16.0.0_r4

REPO_URL="https://android.googlesource.com/platform/frameworks/base"
LIBBASE_URL="https://android.googlesource.com/platform/system/libbase"
SYSTEM_CORE_URL="https://android.googlesource.com/platform/system/core"
NATIVE_URL="https://android.googlesource.com/platform/frameworks/native"
INCFS_URL="https://android.googlesource.com/platform/system/incremental_delivery"
LIBLOG_URL="https://android.googlesource.com/platform/system/logging"
FMTLIB_URL="https://android.googlesource.com/platform/external/fmtlib"
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
/native/android/

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
    echo "Step 5: Initializing libbase repository..."
    if [ -d "libbase" ]; then
        echo "Removing existing libbase directory..."
        rm -rf libbase
    fi
    
    mkdir -p libbase
    cd libbase
    
    git init
    git remote add origin $LIBBASE_URL
    
    echo "Step 6: Configuring sparse checkout for libbase..."
    git config core.sparseCheckout true
    
    # Define sparse checkout paths for android-base headers
    cat > .git/info/sparse-checkout << EOF
# Android base library headers
/include/
EOF
    
    echo "Step 7: Fetching refs/tags/$TAG from libbase (this may take a while)..."
    git fetch --depth 1 origin refs/tags/$TAG:refs/tags/$TAG
    
    echo "Step 8: Checking out tag $TAG..."
    git checkout $TAG
    
    echo "libbase clone completed successfully!"
    cd "$WORK_DIR"
    
    echo ""
    echo "Step 9: Initializing system-core repository..."
    if [ -d "system-core" ]; then
        echo "Removing existing system-core directory..."
        rm -rf system-core
    fi
    
    mkdir -p system-core
    cd system-core
    
    git init
    git remote add origin $SYSTEM_CORE_URL
    
    echo "Step 10: Configuring sparse checkout for system-core..."
    git config core.sparseCheckout true
    
    # Define sparse checkout paths for libutils headers
    cat > .git/info/sparse-checkout << EOF
# libutils headers
/libutils/
/include/
EOF
    
    echo "Step 11: Fetching refs/tags/$TAG from system-core (this may take a while)..."
    git fetch --depth 1 origin refs/tags/$TAG:refs/tags/$TAG
    
    echo "Step 12: Checking out tag $TAG..."
    git checkout $TAG
    
    echo "system-core clone completed successfully!"
    cd "$WORK_DIR"
    
    echo ""
    echo "Step 13: Initializing frameworks-native repository..."
    if [ -d "native" ]; then
        echo "Removing existing native directory..."
        rm -rf native
    fi
    
    mkdir -p native
    cd native
    
    git init
    git remote add origin $NATIVE_URL
    
    echo "Step 14: Configuring sparse checkout for frameworks-native..."
    git config core.sparseCheckout true
    
    # Define sparse checkout paths for native headers
    cat > .git/info/sparse-checkout << EOF
# Native headers
/include/
EOF
    
    echo "Step 15: Fetching refs/tags/$TAG from frameworks-native (this may take a while)..."
    git fetch --depth 1 origin refs/tags/$TAG:refs/tags/$TAG
    
    echo "Step 16: Checking out tag $TAG..."
    git checkout $TAG
    
    echo "frameworks-native clone completed successfully!"
    cd "$WORK_DIR"
    
    echo ""
    echo "Step 17: Initializing incremental_delivery repository..."
    if [ -d "incfs" ]; then
        echo "Removing existing incfs directory..."
        rm -rf incfs
    fi
    
    mkdir -p incfs
    cd incfs
    
    git init
    git remote add origin $INCFS_URL
    
    echo "Step 18: Configuring sparse checkout for incremental_delivery..."
    git config core.sparseCheckout true
    
    # Define sparse checkout paths for incfs util headers
    cat > .git/info/sparse-checkout << EOF
# INCFS util headers
/incfs/util/include/
EOF
    
    echo "Step 19: Fetching refs/tags/$TAG from incremental_delivery (this may take a while)..."
    git fetch --depth 1 origin refs/tags/$TAG:refs/tags/$TAG
    
    echo "Step 20: Checking out tag $TAG..."
    git checkout $TAG
    
    echo "incremental_delivery clone completed successfully!"
    cd "$WORK_DIR"
    
    echo ""
    echo "Step 21: Initializing system-logging repository..."
    if [ -d "liblog" ]; then
        echo "Removing existing liblog directory..."
        rm -rf liblog
    fi
    
    mkdir -p liblog
    cd liblog
    
    git init
    git remote add origin $LIBLOG_URL
    
    echo "Step 22: Configuring sparse checkout for system-logging..."
    git config core.sparseCheckout true
    
    # Define sparse checkout paths for liblog headers
    cat > .git/info/sparse-checkout << EOF
# liblog headers
/liblog/include/
EOF
    
    echo "Step 23: Fetching refs/tags/$TAG from system-logging (this may take a while)..."
    git fetch --depth 1 origin refs/tags/$TAG:refs/tags/$TAG
    
    echo "Step 24: Checking out tag $TAG..."
    git checkout $TAG
    
    echo "system-logging clone completed successfully!"
    cd "$WORK_DIR"
    
    echo ""
    echo "Step 25: Initializing fmtlib repository..."
    if [ -d "fmtlib" ]; then
        echo "Removing existing fmtlib directory..."
        rm -rf fmtlib
    fi
    
    mkdir -p fmtlib
    cd fmtlib
    
    git init
    git remote add origin $FMTLIB_URL
    
    echo "Step 26: Configuring sparse checkout for fmtlib..."
    git config core.sparseCheckout true
    
    # Define sparse checkout paths for fmtlib
    cat > .git/info/sparse-checkout << EOF
# fmtlib source and headers
/include/
/src/
/CMakeLists.txt
EOF
    
    echo "Step 27: Fetching refs/tags/$TAG from fmtlib (this may take a while)..."
    git fetch --depth 1 origin refs/tags/$TAG:refs/tags/$TAG
    
    echo "Step 28: Checking out tag $TAG..."
    git checkout $TAG
    
    echo "fmtlib clone completed successfully!"
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
    
    if ! ldconfig -p | grep -q libfmt.so; then
        MISSING_DEPS+=("libfmt-dev")
    fi
    
    if [ ${#MISSING_DEPS[@]} -ne 0 ]; then
        echo "ERROR: Missing dependencies: ${MISSING_DEPS[*]}"
        echo ""
        echo "On Ubuntu/Debian, install with:"
        echo "sudo apt-get update"
        echo "sudo apt-get install -y ${MISSING_DEPS[*]} build-essential pkg-config libexpat1-dev libpng-dev"
        echo ""
        echo "On macOS, install with:"
        echo "brew install ${MISSING_DEPS[*]} expat libpng fmt"
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

# Build dependencies from source
# Note: Most Android dependencies will just use headers, as they use Android.bp build system
# We add subdirectories for dependencies that have CMakeLists.txt files

# Build fmtlib from source
add_subdirectory(${CMAKE_SOURCE_DIR}/../fmtlib ${CMAKE_BINARY_DIR}/fmt)

# Build libbase from source (Android base library) if available
if(EXISTS ${CMAKE_SOURCE_DIR}/../libbase/CMakeLists.txt)
    add_subdirectory(${CMAKE_SOURCE_DIR}/../libbase ${CMAKE_BINARY_DIR}/libbase)
elseif(EXISTS ${CMAKE_SOURCE_DIR}/../libbase/base/CMakeLists.txt)
    add_subdirectory(${CMAKE_SOURCE_DIR}/../libbase/base ${CMAKE_BINARY_DIR}/libbase)
endif()

# Build liblog from source (Android logging library) if available
if(EXISTS ${CMAKE_SOURCE_DIR}/../liblog/liblog/CMakeLists.txt)
    add_subdirectory(${CMAKE_SOURCE_DIR}/../liblog/liblog ${CMAKE_BINARY_DIR}/liblog)
elseif(EXISTS ${CMAKE_SOURCE_DIR}/../liblog/CMakeLists.txt)
    add_subdirectory(${CMAKE_SOURCE_DIR}/../liblog ${CMAKE_BINARY_DIR}/liblog)
endif()

# Build libutils from source (Android utilities) if available
if(EXISTS ${CMAKE_SOURCE_DIR}/../system-core/libutils/CMakeLists.txt)
    add_subdirectory(${CMAKE_SOURCE_DIR}/../system-core/libutils ${CMAKE_BINARY_DIR}/libutils)
elseif(EXISTS ${CMAKE_SOURCE_DIR}/../system-core/CMakeLists.txt)
    add_subdirectory(${CMAKE_SOURCE_DIR}/../system-core ${CMAKE_BINARY_DIR}/libutils)
endif()

# Build androidfw from source (Android framework library) if available
if(EXISTS ${CMAKE_SOURCE_DIR}/../frameworks-base/libs/androidfw/CMakeLists.txt)
    add_subdirectory(${CMAKE_SOURCE_DIR}/../frameworks-base/libs/androidfw ${CMAKE_BINARY_DIR}/androidfw)
elseif(EXISTS ${CMAKE_SOURCE_DIR}/../frameworks-base/CMakeLists.txt)
    add_subdirectory(${CMAKE_SOURCE_DIR}/../frameworks-base ${CMAKE_BINARY_DIR}/androidfw)
endif()

# Find required system packages
# Note: These are still REQUIRED as some dependencies may not have CMakeLists.txt
# or may need system versions of these libraries for linking
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
    ${CMAKE_SOURCE_DIR}/../libbase/include
    ${CMAKE_SOURCE_DIR}/../system-core/libutils/include
    ${CMAKE_SOURCE_DIR}/../system-core/include
    ${CMAKE_SOURCE_DIR}/../native/include
    ${CMAKE_SOURCE_DIR}/../incfs/incfs/util/include
    ${CMAKE_SOURCE_DIR}/../liblog/liblog/include
    ${CMAKE_SOURCE_DIR}/../fmtlib/include
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
    fmt::fmt
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
    fmt::fmt
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
        fmt::fmt
        ${ZLIB_LIBRARIES}
        PNG::PNG
        ${EXPAT_LIBRARIES}
        pthread
    )
    
    # Build 64-bit version
    add_executable(aapt_64 ${AAPT_SOURCES})
    set_target_properties(aapt_64 PROPERTIES COMPILE_FLAGS "-m64")
    target_link_libraries(aapt_64 
        fmt::fmt
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
