#!/bin/bash
# N1OS Rootfs Setup Script
# Creates a minimal Alpine-based rootfs for PinePhone
set -euo pipefail

ROOTFS_DIR="${N1OS_BUILD}/rootfs"
ALPINE_MIRROR="http://dl-cdn.alpinelinux.org/alpine/v3.21"
ALPINE_ARCH="aarch64"

echo "=== N1OS Rootfs Builder ==="
echo "Target: ${ROOTFS_DIR}"

# --- Step 1: Bootstrap Alpine minimal rootfs ---
echo "[1/8] Bootstrapping Alpine rootfs..."
mkdir -p "${ROOTFS_DIR}"
# Copy host keys so apk trusts the repos
mkdir -p "${ROOTFS_DIR}/etc/apk/keys"
cp /etc/apk/keys/* "${ROOTFS_DIR}/etc/apk/keys/" 2>/dev/null || true
apk --arch "${ALPINE_ARCH}" \
    --root "${ROOTFS_DIR}" \
    --repository "${ALPINE_MIRROR}/main" \
    --repository "${ALPINE_MIRROR}/community" \
    --initdb --no-cache --allow-untrusted \
    add alpine-base openrc

# --- Step 2: Install essential packages ---
echo "[2/8] Installing system packages..."
apk --root "${ROOTFS_DIR}" \
    --repository "${ALPINE_MIRROR}/main" \
    --repository "${ALPINE_MIRROR}/community" \
    --no-cache --allow-untrusted add \
    openrc seatd wlroots \
    foot ncurses \
    iwd dhcpcd \
    pipewire pipewire-pulse wireplumber \
    libinput \
    mesa-dri-gallium \
    eudev kmod util-linux e2fsprogs \
    zram-init \
    modemmanager \
    font-dejavu \
    dbus bash pango cairo

# --- Step 3: Configure OpenRC services ---
echo "[3/8] Configuring OpenRC..."
# Enable only essential services for fast boot
chroot "${ROOTFS_DIR}" /bin/sh -c '
    # Boot-critical
    rc-update add devfs sysinit
    rc-update add dmesg sysinit
    rc-update add mdev sysinit
    rc-update add hwdrivers sysinit

    # Boot
    rc-update add modules boot
    rc-update add hostname boot
    rc-update add sysctl boot
    rc-update add bootmisc boot
    rc-update add syslog boot

    # Default runlevel — minimal
    rc-update add dbus default
    rc-update add seatd default
    rc-update add iwd default
    rc-update add dhcpcd default
    rc-update add udev-trigger default
    rc-update add zram-init default

    # Explicitly disable slow/unnecessary services
    rc-update del swap boot 2>/dev/null || true
    rc-update del hwclock boot 2>/dev/null || true
    rc-update del consolefont boot 2>/dev/null || true
'

# --- Step 4: Configure zram ---
echo "[4/8] Configuring zram swap..."
mkdir -p "${ROOTFS_DIR}/etc/conf.d"
cat > "${ROOTFS_DIR}/etc/conf.d/zram-init" << 'ZRAMEOF'
# N1OS zram configuration — 50% of RAM (1GB on 2GB PinePhone)
num_devices=1
type0="swap"
size0=1024
algo0=lz4
ZRAMEOF

# --- Step 5: Configure N1OS identity ---
echo "[5/8] Applying N1OS branding..."
cp /src/branding/os-release "${ROOTFS_DIR}/etc/os-release"
cp /src/branding/motd "${ROOTFS_DIR}/etc/motd"
mkdir -p "${ROOTFS_DIR}/usr/share/n1os"
cp /src/branding/logo.txt "${ROOTFS_DIR}/usr/share/n1os/logo.txt" 2>/dev/null || true
echo "n1os" > "${ROOTFS_DIR}/etc/hostname"

# Install n1shell compositor
echo "  Installing n1shell compositor..."
cp "${N1OS_OUT}/n1shell" "${ROOTFS_DIR}/usr/bin/n1shell"
chmod +x "${ROOTFS_DIR}/usr/bin/n1shell"

# --- Step 6: Configure Sway for PinePhone ---
echo "[6/8] Configuring Sway compositor..."
mkdir -p "${ROOTFS_DIR}/etc/sway"
cat > "${ROOTFS_DIR}/etc/sway/config" << 'SWAYEOF'
# N1OS Sway Configuration — PinePhone optimized
# Compositor settings
output DSI-1 {
    scale 2
    transform 0
}

# Use foot terminal
set $term foot

# Touch-friendly
input "type:touch" {
    map_to_output DSI-1
}

input "type:pointer" {
    natural_scroll enabled
}

# Disable titlebars for max screen space
default_border none
default_floating_border none
titlebar_padding 0
gaps inner 0
gaps outer 0

# Status bar
bar {
    position top
    height 24
    status_command while date +'%H:%M %d/%m'; do sleep 30; done
    colors {
        background #000000cc
        statusline #ffffff
    }
}

# Auto-start
exec_always {
    # Set environment for Wayland
    export XDG_SESSION_TYPE=wayland
    export XDG_RUNTIME_DIR=/run/user/1000
    export WLR_RENDERER=gles2
    export WLR_DRM_DEVICES=/dev/dri/card0
}

# N1OS TUI launcher on boot
exec foot -e /usr/bin/n1tui
SWAYEOF

# --- Step 7: Create N1OS TUI launcher ---
echo "[7/8] Creating N1OS TUI interface..."
cat > "${ROOTFS_DIR}/usr/bin/n1tui" << 'TUIEOF'
#!/bin/bash
# N1OS TUI — Main interface
clear
cat /usr/share/n1os/logo.txt
echo ""
echo "  System Status"
echo "  ─────────────"
printf "  CPU:     %s\n" "$(cat /proc/cpuinfo | grep 'model name' | head -1 | cut -d: -f2 | xargs)"
printf "  Memory:  %s / %s\n" "$(free -h | awk '/Mem:/{print $3}')" "$(free -h | awk '/Mem:/{print $2}')"
printf "  Storage: %s\n" "$(df -h / | awk 'NR==2{print $3 "/" $2 " (" $5 " used)"}')"
printf "  Battery: %s\n" "$(cat /sys/class/power_supply/axp20x-battery/capacity 2>/dev/null || echo 'N/A')%"
echo ""
echo "  [1] Terminal    [2] WiFi    [3] Phone"
echo "  [4] Settings    [5] Files   [q] Power"
echo ""

while true; do
    read -rsn1 key
    case "$key" in
        1) exec bash ;;
        2) exec nmtui 2>/dev/null || echo "WiFi: use 'iwctl'" ;;
        3) echo "  Modem interface coming soon..." ;;
        4) echo "  Settings coming soon..." ;;
        5) exec ls -la --color ;;
        q)
            echo "  [r] Reboot  [s] Shutdown  [c] Cancel"
            read -rsn1 pkey
            case "$pkey" in
                r) reboot ;;
                s) poweroff ;;
                *) ;;
            esac
            ;;
    esac
done
TUIEOF
chmod +x "${ROOTFS_DIR}/usr/bin/n1tui"

# n1help command
cat > "${ROOTFS_DIR}/usr/bin/n1help" << 'HELPEOF'
#!/bin/bash
echo "N1OS System Commands"
echo "===================="
echo "  n1tui      - Launch N1OS TUI interface"
echo "  n1wifi     - WiFi manager (iwctl)"
echo "  n1modem    - Modem status"
echo "  n1battery  - Battery status"
echo "  n1help     - This help message"
echo ""
echo "System:"
echo "  sway       - Start compositor"
echo "  foot       - Terminal emulator"
echo "  poweroff   - Shutdown"
echo "  reboot     - Restart"
HELPEOF
chmod +x "${ROOTFS_DIR}/usr/bin/n1help"

# --- Step 8: Create n1os user ---
echo "[8/8] Creating user account..."
chroot "${ROOTFS_DIR}" /bin/sh -c '
    adduser -D -s /bin/bash -h /home/n1os n1os
    echo "n1os:n1os" | chpasswd
    addgroup n1os wheel
    addgroup n1os video
    addgroup n1os audio
    addgroup n1os input
    addgroup n1os seat
'

# Auto-login + auto-start sway
mkdir -p "${ROOTFS_DIR}/etc/init.d"
cat > "${ROOTFS_DIR}/etc/init.d/n1os-session" << 'SESSIONEOF'
#!/sbin/openrc-run
description="N1OS Shell Session"
depend() {
    need seatd dbus
    after *
}
start() {
    ebegin "Starting N1OS Shell"
    start-stop-daemon --start --background \
        --user n1os \
        --env XDG_RUNTIME_DIR=/run/user/1000 \
        --env WLR_RENDERER=gles2 \
        --env WLR_DRM_DEVICES=/dev/dri/card0 \
        --exec /usr/bin/n1shell
    eend $?
}
stop() {
    ebegin "Stopping N1OS Shell"
    start-stop-daemon --stop --exec /usr/bin/n1shell
    eend $?
}
SESSIONEOF
chmod +x "${ROOTFS_DIR}/etc/init.d/n1os-session"
chroot "${ROOTFS_DIR}" rc-update add n1os-session default

# Create XDG runtime dir
mkdir -p "${ROOTFS_DIR}/run/user/1000"
chroot "${ROOTFS_DIR}" chown 1000:1000 /run/user/1000

# Set CPU governor to schedutil at boot
cat > "${ROOTFS_DIR}/etc/local.d/cpufreq.start" << 'CPUEOF'
#!/bin/sh
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo schedutil > "$cpu" 2>/dev/null
done
CPUEOF
chmod +x "${ROOTFS_DIR}/etc/local.d/cpufreq.start"

echo ""
echo "=== N1OS Rootfs Complete ==="
echo "Size: $(du -sh ${ROOTFS_DIR} | cut -f1)"
