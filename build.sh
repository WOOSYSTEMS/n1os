#!/bin/bash
# N1OS Master Build Script
# Builds a complete PinePhone image inside Docker
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOCKER="${DOCKER:-docker}"
IMAGE_NAME="n1os-builder"
CONTAINER_NAME="n1os-build"

echo ""
echo "    ███╗   ██╗ ██╗ ██████╗ ███████╗"
echo "    ████╗  ██║███║██╔═══██╗██╔════╝"
echo "    ██╔██╗ ██║╚██║██║   ██║███████╗"
echo "    ██║╚██╗██║ ██║██║   ██║╚════██║"
echo "    ██║ ╚████║ ██║╚██████╔╝███████║"
echo "    ╚═╝  ╚═══╝ ╚═╝ ╚═════╝ ╚══════╝"
echo "         Build System v1.0.0"
echo ""

STEP="${1:-all}"

# --- Build Docker image ---
build_docker() {
    echo "=== Building Docker build environment ==="
    ${DOCKER} build \
        --platform linux/arm64 \
        -t "${IMAGE_NAME}" \
        -f "${SCRIPT_DIR}/Dockerfile.build" \
        "${SCRIPT_DIR}"
    echo "Docker build environment ready."
}

# --- Run a build step inside Docker ---
run_in_docker() {
    local script="$1"
    shift
    ${DOCKER} run --rm \
        --platform linux/arm64 \
        --privileged \
        --name "${CONTAINER_NAME}" \
        -v "${SCRIPT_DIR}:/src:ro" \
        -v "${SCRIPT_DIR}/out:/out" \
        -v "n1os-build-cache:/build" \
        -e N1OS_BUILD=/build \
        -e N1OS_OUT=/out \
        "${IMAGE_NAME}" \
        bash "/src/${script}" "$@"
}

# --- Build steps ---
step_docker() {
    build_docker
}

step_uboot() {
    echo ""
    echo "=== Phase 1: U-Boot Bootloader ==="
    run_in_docker scripts/build_uboot.sh
}

step_kernel() {
    echo ""
    echo "=== Phase 2: Linux Kernel ==="
    run_in_docker scripts/build_kernel.sh
}

step_rootfs() {
    echo ""
    echo "=== Phase 3: Root Filesystem ==="
    run_in_docker rootfs/setup_rootfs.sh
}

step_image() {
    echo ""
    echo "=== Phase 4: Disk Image ==="
    run_in_docker scripts/mkimage.sh
}

# --- Orchestrate ---
case "${STEP}" in
    docker)
        step_docker
        ;;
    uboot)
        step_uboot
        ;;
    kernel)
        step_kernel
        ;;
    rootfs)
        step_rootfs
        ;;
    image)
        step_image
        ;;
    all)
        step_docker
        step_uboot
        step_kernel
        step_rootfs
        step_image
        ;;
    clean)
        echo "Cleaning build cache..."
        ${DOCKER} volume rm n1os-build-cache 2>/dev/null || true
        rm -rf "${SCRIPT_DIR}/out"
        echo "Clean."
        ;;
    *)
        echo "Usage: $0 {all|docker|uboot|kernel|rootfs|image|clean}"
        echo ""
        echo "Steps:"
        echo "  docker  - Build the Docker build environment"
        echo "  uboot   - Build U-Boot bootloader"
        echo "  kernel  - Build mainline Linux kernel"
        echo "  rootfs  - Build Alpine-based root filesystem"
        echo "  image   - Assemble bootable .img file"
        echo "  all     - Run all steps"
        echo "  clean   - Remove build cache and output"
        exit 1
        ;;
esac

echo ""
echo "=== Build Complete ==="
