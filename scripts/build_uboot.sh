#!/bin/bash
# N1OS U-Boot Builder for PinePhone
set -euo pipefail

UBOOT_VERSION="${UBOOT_VERSION:-2024.07}"
UBOOT_DIR="${N1OS_BUILD}/u-boot-${UBOOT_VERSION}"
UBOOT_URL="https://ftp.denx.de/pub/u-boot/u-boot-${UBOOT_VERSION}.tar.bz2"
ATF_DIR="${N1OS_BUILD}/arm-trusted-firmware"

# Native ARM64 build — no cross-compile prefix needed
unset CROSS_COMPILE

echo "=== N1OS U-Boot Builder ==="
echo "Version: ${UBOOT_VERSION}"

# --- Build SCP firmware (Crust) for suspend support ---
echo "[0/4] Building Crust SCP firmware..."
CRUST_DIR="${N1OS_BUILD}/crust"
if [ ! -d "${CRUST_DIR}" ]; then
    cd "${N1OS_BUILD}"
    git clone --depth 1 https://github.com/crust-firmware/crust.git
fi

# Crust needs an or1k cross-compiler - install if not present
if ! command -v or1k-elf-gcc &>/dev/null; then
    echo "  Installing or1k cross-compiler for SCP firmware..."
    # Build a minimal or1k toolchain or use prebuilt
    # For now, create a dummy scp.bin and set BINMAN_ALLOW_MISSING
    echo "  Skipping Crust build (or1k compiler not available)"
    echo "  SCP firmware is optional — suspend will not work without it"
    export SCP=/dev/null
fi

# --- Build ARM Trusted Firmware (BL31) ---
echo "[1/4] Building ARM Trusted Firmware..."
if [ ! -d "${ATF_DIR}" ]; then
    cd "${N1OS_BUILD}"
    git clone --depth 1 https://github.com/ARM-software/arm-trusted-firmware.git
fi
cd "${ATF_DIR}"
make PLAT=sun50i_a64 DEBUG=0 \
    CC=gcc LD=gcc AR=ar AS=gcc NM=nm \
    OBJCOPY=objcopy OBJDUMP=objdump READELF=readelf \
    bl31
export BL31="${ATF_DIR}/build/sun50i_a64/release/bl31.bin"
echo "BL31: ${BL31}"

# --- Download U-Boot ---
if [ ! -d "${UBOOT_DIR}" ]; then
    echo "[2/4] Downloading U-Boot ${UBOOT_VERSION}..."
    cd "${N1OS_BUILD}"
    wget -q --show-progress "${UBOOT_URL}" -O "u-boot-${UBOOT_VERSION}.tar.bz2"
    tar xf "u-boot-${UBOOT_VERSION}.tar.bz2"
    rm "u-boot-${UBOOT_VERSION}.tar.bz2"
else
    echo "[2/4] U-Boot source already present."
fi

cd "${UBOOT_DIR}"

# --- Configure ---
echo "[3/4] Configuring U-Boot for PinePhone..."
make pinephone_defconfig

# Apply N1OS customizations
sed -i 's/CONFIG_BOOTDELAY=.*/CONFIG_BOOTDELAY=0/' .config

# Disable in-tree pylibfdt build (use system py3-libfdt instead)
sed -i 's/CONFIG_PYLIBFDT=y/# CONFIG_PYLIBFDT is not set/' .config

# --- Build ---
echo "[4/4] Building U-Boot..."
make -j$(nproc) NO_PYTHON=1 BINMAN_ALLOW_MISSING=1 SCP=/dev/null 2>&1 | tail -20

# --- Copy artifacts ---
cp u-boot-sunxi-with-spl.bin "${N1OS_OUT}/u-boot-sunxi-with-spl.bin"

echo ""
echo "=== U-Boot Build Complete ==="
echo "Output: ${N1OS_OUT}/u-boot-sunxi-with-spl.bin ($(du -sh ${N1OS_OUT}/u-boot-sunxi-with-spl.bin | cut -f1))"
