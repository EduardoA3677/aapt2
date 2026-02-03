# Makefile for building AAPT2 from Android source
# Usage:
#   make clone    - Clone necessary files from Android source
#   make deps     - Install build dependencies
#   make all      - Build all binaries (aapt2, aapt2_64, aapt, aapt_64)
#   make clean    - Clean build artifacts

REPO_URL := https://android.googlesource.com/platform/frameworks/base
TAG := android-16.0.0_r4
SRC_DIR := frameworks-base
BUILD_DIR := build
INSTALL_DIR := /usr/local/bin

# Compiler settings
CXX := g++
CXXFLAGS := -std=c++17 -O2 -Wall
CXXFLAGS_64 := $(CXXFLAGS) -m64
LDFLAGS := -lprotobuf -lz -lpng -lexpat -lpthread

# Source directories
AAPT2_SRC_DIR := $(SRC_DIR)/tools/aapt2
AAPT_SRC_DIR := $(SRC_DIR)/tools/aapt
ANDROIDFW_DIR := $(SRC_DIR)/libs/androidfw

# Include paths
INCLUDES := -I$(AAPT2_SRC_DIR) \
            -I$(AAPT2_SRC_DIR)/include \
            -I$(ANDROIDFW_DIR)/include \
            -I$(SRC_DIR)/include

# Binaries to build
BINARIES := aapt2 aapt2_64 aapt aapt_64

.PHONY: all clone deps clean install help

help:
	@echo "AAPT2 Build System"
	@echo "=================="
	@echo ""
	@echo "Available targets:"
	@echo "  make clone    - Clone necessary files from Android source (tag: $(TAG))"
	@echo "  make deps     - Install build dependencies"
	@echo "  make all      - Build all binaries"
	@echo "  make clean    - Clean build artifacts"
	@echo "  make install  - Install binaries to $(INSTALL_DIR)"
	@echo ""
	@echo "Quick start:"
	@echo "  make clone && make deps && make all"

all: check-source
	@echo "Building AAPT2 binaries..."
	@echo "Note: This Makefile provides the structure."
	@echo "Use clone_and_build.sh for automated building."
	@mkdir -p $(BUILD_DIR)

clone:
	@echo "Cloning Android source (sparse checkout)..."
	@if [ -d "$(SRC_DIR)" ]; then \
		echo "Source directory already exists. Skipping clone."; \
	else \
		./clone_and_build.sh clone-only || \
		(echo "Error: Cannot clone. Use the clone_and_build.sh script."; exit 1); \
	fi

check-source:
	@if [ ! -d "$(SRC_DIR)" ]; then \
		echo "Error: Source directory not found. Run 'make clone' first."; \
		exit 1; \
	fi

deps:
	@echo "Installing build dependencies..."
	@echo "Detecting OS..."
	@if [ -f /etc/debian_version ]; then \
		echo "Debian/Ubuntu detected"; \
		sudo apt-get update; \
		sudo apt-get install -y \
			build-essential \
			cmake \
			ninja-build \
			pkg-config \
			protobuf-compiler \
			libprotobuf-dev \
			zlib1g-dev \
			libpng-dev \
			libexpat1-dev; \
	elif [ -f /etc/redhat-release ]; then \
		echo "RedHat/CentOS detected"; \
		sudo yum install -y \
			gcc-c++ \
			cmake \
			ninja-build \
			pkgconfig \
			protobuf-compiler \
			protobuf-devel \
			zlib-devel \
			libpng-devel \
			expat-devel; \
	elif [ "$$(uname)" = "Darwin" ]; then \
		echo "macOS detected"; \
		brew install \
			cmake \
			ninja \
			pkg-config \
			protobuf \
			zlib \
			libpng \
			expat; \
	else \
		echo "Unknown OS. Please install dependencies manually:"; \
		echo "  - CMake (>= 3.10)"; \
		echo "  - Ninja build"; \
		echo "  - Protobuf compiler"; \
		echo "  - Development libraries: zlib, libpng, expat"; \
	fi

clean:
	@echo "Cleaning build artifacts..."
	rm -rf $(BUILD_DIR)
	rm -f aapt2 aapt2_64 aapt aapt_64

install: all
	@echo "Installing binaries to $(INSTALL_DIR)..."
	@if [ -f "$(BUILD_DIR)/aapt2" ]; then \
		sudo install -m 755 $(BUILD_DIR)/aapt2 $(INSTALL_DIR)/; \
	fi
	@if [ -f "$(BUILD_DIR)/aapt2_64" ]; then \
		sudo install -m 755 $(BUILD_DIR)/aapt2_64 $(INSTALL_DIR)/; \
	fi
	@if [ -f "$(BUILD_DIR)/aapt" ]; then \
		sudo install -m 755 $(BUILD_DIR)/aapt $(INSTALL_DIR)/; \
	fi
	@if [ -f "$(BUILD_DIR)/aapt_64" ]; then \
		sudo install -m 755 $(BUILD_DIR)/aapt_64 $(INSTALL_DIR)/; \
	fi
	@echo "Installation complete!"

# Display build status
status:
	@echo "Build Status:"
	@echo "============="
	@echo "Source directory: $$(if [ -d '$(SRC_DIR)' ]; then echo 'Present'; else echo 'Missing (run: make clone)'; fi)"
	@echo "Build directory: $$(if [ -d '$(BUILD_DIR)' ]; then echo 'Present'; else echo 'Not created'; fi)"
	@echo ""
	@echo "Built binaries:"
	@for bin in $(BINARIES); do \
		if [ -f "$(BUILD_DIR)/$$bin" ]; then \
			echo "  ✓ $$bin"; \
		else \
			echo "  ✗ $$bin (not built)"; \
		fi \
	done
