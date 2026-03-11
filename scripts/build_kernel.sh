#!/bin/bash
# N1OS Kernel Builder — Mainline Linux for PinePhone
set -euo pipefail

KERNEL_VERSION="${KERNEL_VERSION:-6.12.8}"
KERNEL_DIR="${N1OS_BUILD}/linux-${KERNEL_VERSION}"
KERNEL_URL="https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-${KERNEL_VERSION}.tar.xz"

echo "=== N1OS Kernel Builder ==="
echo "Version: ${KERNEL_VERSION}"
echo "Target:  PinePhone (sun50i-a64)"

# --- Download kernel ---
if [ ! -d "${KERNEL_DIR}" ]; then
    echo "[1/4] Downloading kernel ${KERNEL_VERSION}..."
    cd "${N1OS_BUILD}"
    wget -q --show-progress "${KERNEL_URL}" -O "linux-${KERNEL_VERSION}.tar.xz"
    tar xf "linux-${KERNEL_VERSION}.tar.xz"
    rm "linux-${KERNEL_VERSION}.tar.xz"
else
    echo "[1/4] Kernel source already present, skipping download."
fi

cd "${KERNEL_DIR}"

# --- Configure ---
echo "[2/4] Configuring kernel..."
make mrproper
make defconfig
# Merge PinePhone-specific config (disables non-sunxi platforms)
./scripts/kconfig/merge_config.sh .config /src/configs/kernel_pinephone.config

# --- Build ---
echo "[3/4] Building kernel (this takes a while)..."
NPROC=$(nproc)
echo "Using ${NPROC} parallel jobs"
make -j${NPROC} Image modules dtbs 2>&1 | tail -20

# --- Install ---
echo "[4/4] Installing kernel artifacts..."
mkdir -p "${N1OS_OUT}/boot" "${N1OS_OUT}/lib/modules"

# Kernel image
cp arch/arm64/boot/Image "${N1OS_OUT}/boot/Image"

# Device tree
cp arch/arm64/boot/dts/allwinner/sun50i-a64-pinephone-1.2.dtb \
   "${N1OS_OUT}/boot/sun50i-a64-pinephone.dtb" 2>/dev/null || \
cp arch/arm64/boot/dts/allwinner/sun50i-a64-pinephone*.dtb \
   "${N1OS_OUT}/boot/" 2>/dev/null || true

# Modules
make modules_install INSTALL_MOD_PATH="${N1OS_OUT}" INSTALL_MOD_STRIP=1

echo ""
echo "=== Kernel Build Complete ==="
echo "Image: ${N1OS_OUT}/boot/Image ($(du -sh ${N1OS_OUT}/boot/Image | cut -f1))"
echo "DTB:   ${N1OS_OUT}/boot/sun50i-a64-pinephone.dtb"
echo "Modules: ${N1OS_OUT}/lib/modules/"
