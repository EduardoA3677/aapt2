# Installation Guide - AAPT2 Build System

## Quick Start

For the impatient, here's the fastest way to get started:

```bash
git clone <this-repository>
cd aapt2
./clone_and_build.sh
```

## Detailed Installation Instructions

### Step 1: System Requirements

#### Minimum Hardware
- **CPU**: Dual-core processor (Quad-core recommended)
- **RAM**: 4 GB minimum (8 GB recommended)
- **Disk Space**: 5 GB free space
- **Internet**: Required for cloning Android source

#### Supported Operating Systems
- Ubuntu 18.04, 20.04, 22.04, 24.04
- Debian 10, 11, 12
- Fedora 35+
- macOS 11+ (Big Sur or later)
- Windows 10/11 with WSL2 (Ubuntu 20.04 or 22.04)

### Step 2: Install Dependencies

#### Ubuntu/Debian

```bash
sudo apt-get update
sudo apt-get install -y \
    git \
    build-essential \
    cmake \
    ninja-build \
    pkg-config \
    protobuf-compiler \
    libprotobuf-dev \
    zlib1g-dev \
    libpng-dev \
    libexpat1-dev \
    libfmt-dev
```

#### Fedora/RHEL/CentOS

```bash
sudo dnf install -y \
    git \
    gcc-c++ \
    cmake \
    ninja-build \
    pkgconfig \
    protobuf-compiler \
    protobuf-devel \
    zlib-devel \
    libpng-devel \
    expat-devel \
    fmt-devel
```

#### macOS

First, install Homebrew if you haven't already:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Then install dependencies:
```bash
brew install \
    git \
    cmake \
    ninja \
    pkg-config \
    protobuf \
    zlib \
    libpng \
    expat \
    fmt
```

#### Windows (WSL2)

1. Install WSL2:
```powershell
wsl --install -d Ubuntu-22.04
```

2. Open Ubuntu and follow the Ubuntu/Debian instructions above.

### Step 3: Clone This Repository

```bash
git clone <repository-url>
cd aapt2
```

### Step 4: Build AAPT2

#### Automated Build (Recommended)

```bash
./clone_and_build.sh
```

This script will:
1. Clone only necessary files from Android source (sparse checkout)
2. Verify all dependencies are installed
3. Generate build files
4. Compile all four binaries

#### Manual Build

If you prefer step-by-step control:

```bash
# Step 1: Clone Android source
make clone

# Step 2: Verify dependencies
make deps

# Step 3: Build binaries
make all

# Step 4: Check build status
make status
```

### Step 5: Verify Installation

After successful build:

```bash
# Check if binaries were created
ls -lh build/

# Test AAPT2
./build/aapt2 version

# Test AAPT
./build/aapt version
```

### Step 6: Install System-Wide (Optional)

To install binaries to `/usr/local/bin`:

```bash
sudo make install
```

Or manually:

```bash
sudo cp build/aapt2 /usr/local/bin/
sudo cp build/aapt2_64 /usr/local/bin/
sudo cp build/aapt /usr/local/bin/
sudo cp build/aapt_64 /usr/local/bin/
sudo chmod +x /usr/local/bin/aapt*
```

Verify installation:

```bash
which aapt2
aapt2 version
```

## Platform-Specific Notes

### Ubuntu 24.04

Ubuntu 24.04 uses newer compiler versions. If you encounter issues:

```bash
# Use GCC 11 if needed
sudo apt-get install gcc-11 g++-11
export CC=gcc-11
export CXX=g++-11
```

### macOS Apple Silicon (M1/M2/M3)

```bash
# You may need Rosetta 2 for some dependencies
softwareupdate --install-rosetta

# Build for native ARM64
arch -arm64 ./clone_and_build.sh

# Or build for x86_64 (via Rosetta)
arch -x86_64 ./clone_and_build.sh
```

### Windows WSL2

Ensure WSL2 is up to date:

```bash
wsl --update
wsl --shutdown
# Restart WSL
```

For better performance, clone the repository inside WSL (not on /mnt/c/):

```bash
cd ~
git clone <repository-url>
cd aapt2
```

## Troubleshooting

### Issue: Cannot access android.googlesource.com

**Solution 1**: Check internet connection and firewall
```bash
ping android.googlesource.com
```

**Solution 2**: Use a VPN or proxy if the domain is blocked

**Solution 3**: Use a mirror (if available)

### Issue: Protobuf version mismatch

```bash
# Check protobuf version
protoc --version

# Should be 3.x or higher
# If too old, install from source:
wget https://github.com/protocolbuffers/protobuf/releases/download/v21.12/protobuf-all-21.12.tar.gz
tar xzf protobuf-all-21.12.tar.gz
cd protobuf-21.12
./configure
make -j$(nproc)
sudo make install
sudo ldconfig
```

### Issue: CMake not found or too old

```bash
# Install latest CMake
wget https://github.com/Kitware/CMake/releases/download/v3.27.7/cmake-3.27.7-linux-x86_64.sh
chmod +x cmake-3.27.7-linux-x86_64.sh
sudo ./cmake-3.27.7-linux-x86_64.sh --skip-license --prefix=/usr/local
```

### Issue: Build fails with "undefined reference"

This usually means a library is missing:

```bash
# Check what libraries are available
ldconfig -p | grep -E "(protobuf|png|expat|z|fmt)"

# Reinstall development packages
sudo apt-get install --reinstall \
    libprotobuf-dev \
    libpng-dev \
    libexpat1-dev \
    zlib1g-dev \
    libfmt-dev
```

### Issue: Out of memory during build

```bash
# Reduce parallel jobs
make -j2  # Use only 2 cores

# Or in clone_and_build.sh, modify:
# make -j$(nproc) to make -j2
```

### Issue: Permission denied when cloning

```bash
# Ensure git is configured
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# If behind a proxy
git config --global http.proxy http://proxy.example.com:8080
```

## Advanced Configuration

### Custom Build Options

Edit `clone_and_build.sh` to customize:

```bash
# Change Android source tag
TAG="android-16.0.0_r5"  # Use a different tag

# Change build type
CMAKE_BUILD_TYPE="Debug"  # For debugging
CMAKE_BUILD_TYPE="Release"  # For production (default)

# Enable verbose output
make VERBOSE=1
```

### Cross-Compilation

To build for different architectures:

```bash
# For 32-bit on 64-bit system
./clone_and_build.sh --arch=32

# For ARM64
export CC=aarch64-linux-gnu-gcc
export CXX=aarch64-linux-gnu-g++
./clone_and_build.sh
```

### Building Specific Binaries

If you only need specific binaries:

```bash
# Edit CMakeLists.txt and comment out unwanted binaries
# Then rebuild
cd build
cmake ..
make aapt2  # Build only aapt2
```

## Verification

### Smoke Test

```bash
# Create a simple test
mkdir -p test/res/values
echo '<?xml version="1.0" encoding="utf-8"?><resources><string name="app_name">Test</string></resources>' > test/res/values/strings.xml

# Compile with AAPT2
./build/aapt2 compile -o test/compiled.zip test/res/values/strings.xml

# Verify
./build/aapt2 dump test/compiled.zip
```

### Performance Test

```bash
# Time the compilation
time ./build/aapt2 version

# Should complete in < 0.1 seconds
```

## Next Steps

After successful installation:

1. **Read the README.md** for usage examples
2. **Test with real Android projects** 
3. **Integrate into build scripts**
4. **Report issues** if you encounter problems

## Getting Help

- **Documentation**: See README.md
- **Issues**: Open a GitHub issue
- **Android Docs**: https://developer.android.com/tools/aapt2
- **AOSP Docs**: https://source.android.com/

## Updates

To update to a newer Android version:

```bash
# Edit clone_and_build.sh
# Change TAG="android-16.0.0_r4" to new tag

# Clean previous build
make clean
rm -rf frameworks-base

# Rebuild
./clone_and_build.sh
```

## Uninstallation

To remove installed binaries:

```bash
sudo rm /usr/local/bin/aapt
sudo rm /usr/local/bin/aapt_64
sudo rm /usr/local/bin/aapt2
sudo rm /usr/local/bin/aapt2_64
```

To remove build files:

```bash
make clean
rm -rf frameworks-base
```

To remove the repository:

```bash
cd ..
rm -rf aapt2
```
