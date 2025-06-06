#!/bin/bash

# Directories
BASE_DIR=$(pwd)
CLANG_DIR="$BASE_DIR/clang/bin"
OUT_DIR="$BASE_DIR/out"
ANYKERNEL_DIR="$BASE_DIR/AnyKernel3/r8q"
DTB_OUT="$OUT_DIR/arch/arm64/boot/dts/vendor/qcom"
IMAGE_OUT="$OUT_DIR/arch/arm64/boot/Image"
KERNEL_NAME="not_kernel+blazex-$(date +%Y%m%d)+r8q"

# Build Environment
export ARCH=arm64
export SUBARCH=arm64
export PATH="$CLANG_DIR:/usr/bin:$PATH"
BUILD_ENV="ARCH=arm64 CC=clang CROSS_COMPILE=aarch64-linux-gnu- LLVM=1 LLVM_IAS=1"
KERNEL_MAKE_ENV="DTC_EXT=${BASE_DIR}/tools/dtc CONFIG_BUILD_ARM64_DT_OVERLAY=y"

# Clean up old files
rm -rf "$IMAGE_OUT" "$ANYKERNEL_DIR/dtb" "$OUT_DIR/.version" "$OUT_DIR/.local"
mkdir -p "$ANYKERNEL_DIR"

# Configure kernel
make O="$OUT_DIR" $BUILD_ENV vendor/kona-not_defconfig vendor/samsung/r8q.config vendor/debugfs.config

# Build DTBs
make -j$(nproc) O="$OUT_DIR" $BUILD_ENV dtbs
cat "$DTB_OUT"/*.dtb > "$ANYKERNEL_DIR/dtb"

# Build Image
make -j$(nproc) O="$OUT_DIR" $KERNEL_MAKE_ENV $BUILD_ENV Image
cp "$IMAGE_OUT" "$ANYKERNEL_DIR/Image"

# Zip flashable kernel
cd "$ANYKERNEL_DIR"
rm -f *.zip
zip -r9 "${KERNEL_NAME}.zip" *

echo "✅ Kernel build complete. Flashable ZIP: $KERNEL_NAME.zip"
