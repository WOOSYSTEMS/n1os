#!/bin/bash
# N1OS Image Assembler — Creates bootable .img for PinePhone SD card
# Uses offset-based access (no loop partition support needed in Docker)
set -euo pipefail

IMG_FILE="${N1OS_OUT}/n1os-pinephone.img"
IMG_SIZE="${IMG_SIZE:-2G}"
BOOT_SIZE_MB=128
ROOTFS_DIR="${N1OS_BUILD}/rootfs"

echo "=== N1OS Image Assembler ==="
echo "Output: ${IMG_FILE}"
echo "Size:   ${IMG_SIZE}"

# Sector math
SECTOR=512
BOOT_START=2048
BOOT_SECTORS=$((BOOT_SIZE_MB * 1024 * 1024 / SECTOR))
ROOT_START=$((BOOT_START + BOOT_SECTORS))

# --- Create empty image ---
echo "[1/7] Creating ${IMG_SIZE} image file..."
rm -f "${IMG_FILE}"
truncate -s "${IMG_SIZE}" "${IMG_FILE}"

# --- Partition table ---
echo "[2/7] Creating partition table..."
sfdisk "${IMG_FILE}" << PARTEOF
label: dos
unit: sectors

${IMG_FILE}1 : start=${BOOT_START}, size=${BOOT_SECTORS}, type=c, bootable
${IMG_FILE}2 : start=${ROOT_START}, type=83
PARTEOF

# --- Create filesystem images separately, then dd them in ---

# Boot partition (FAT32)
echo "[3/7] Creating boot filesystem..."
BOOT_IMG="/tmp/n1os-boot.img"
truncate -s ${BOOT_SIZE_MB}M "${BOOT_IMG}"
mkfs.vfat -F 32 -n N1BOOT "${BOOT_IMG}"

# Mount boot and populate
mkdir -p /mnt/n1boot
mount -o loop "${BOOT_IMG}" /mnt/n1boot

cp "${N1OS_OUT}/boot/Image" /mnt/n1boot/
cp "${N1OS_OUT}/boot/"*.dtb /mnt/n1boot/

# Create boot.cmd for U-Boot
cat > /mnt/n1boot/boot.cmd << 'BOOTCMD'
setenv bootargs console=ttyS0,115200 root=/dev/mmcblk0p2 rootwait rw loglevel=4 splash quiet
load mmc 0:1 ${kernel_addr_r} Image
load mmc 0:1 ${fdt_addr_r} sun50i-a64-pinephone.dtb
booti ${kernel_addr_r} - ${fdt_addr_r}
BOOTCMD

# Compile boot.scr
mkimage -C none -A arm64 -T script -d /mnt/n1boot/boot.cmd /mnt/n1boot/boot.scr 2>/dev/null || true

echo "  Boot contents:"
ls -lh /mnt/n1boot/
umount /mnt/n1boot

# Root partition (ext4)
echo "[4/7] Creating root filesystem..."
TOTAL_SECTORS=$(stat -c%s "${IMG_FILE}" 2>/dev/null || stat -f%z "${IMG_FILE}")
TOTAL_SECTORS=$((TOTAL_SECTORS / SECTOR))
ROOT_SECTORS=$((TOTAL_SECTORS - ROOT_START))
ROOT_SIZE_BYTES=$((ROOT_SECTORS * SECTOR))
ROOT_IMG="/tmp/n1os-root.img"
truncate -s ${ROOT_SIZE_BYTES} "${ROOT_IMG}"
mkfs.ext4 -F -L N1ROOT -O ^metadata_csum "${ROOT_IMG}"

mkdir -p /mnt/n1root
mount -o loop "${ROOT_IMG}" /mnt/n1root

echo "[5/7] Populating rootfs..."
rsync -a "${ROOTFS_DIR}/" /mnt/n1root/

# Copy kernel modules
rsync -a "${N1OS_OUT}/lib/modules/" /mnt/n1root/lib/modules/

# Create fstab
cat > /mnt/n1root/etc/fstab << 'FSTAB'
# N1OS fstab
/dev/mmcblk0p2  /       ext4    defaults,noatime,nodiratime  0 1
/dev/mmcblk0p1  /boot   vfat    defaults,ro                  0 2
tmpfs           /tmp    tmpfs   defaults,nosuid,nodev,size=256M  0 0
tmpfs           /run    tmpfs   defaults,nosuid,nodev        0 0
FSTAB

echo "  Rootfs usage:"
df -h /mnt/n1root
umount /mnt/n1root

# --- Assemble image ---
echo "[6/7] Assembling disk image..."

# Write boot partition at offset
dd if="${BOOT_IMG}" of="${IMG_FILE}" bs=${SECTOR} seek=${BOOT_START} conv=notrunc status=none

# Write root partition at offset
dd if="${ROOT_IMG}" of="${IMG_FILE}" bs=${SECTOR} seek=${ROOT_START} conv=notrunc status=none

# Write U-Boot at 8KB offset (sector 16)
echo "[7/7] Writing U-Boot bootloader..."
dd if="${N1OS_OUT}/u-boot-sunxi-with-spl.bin" of="${IMG_FILE}" bs=1024 seek=8 conv=notrunc

# Cleanup temp files
rm -f "${BOOT_IMG}" "${ROOT_IMG}"

# --- Compress ---
echo "Compressing image..."
xz -T0 -3 "${IMG_FILE}"

echo ""
echo "=== N1OS Image Complete ==="
echo "Output: ${IMG_FILE}.xz ($(du -sh ${IMG_FILE}.xz | cut -f1))"
echo ""
echo "Flash to SD card with:"
echo "  xzcat n1os-pinephone.img.xz | sudo dd of=/dev/sdX bs=4M status=none"
echo ""
cat /src/branding/logo.txt
