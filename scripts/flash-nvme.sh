#!/usr/bin/env bash
set -e

BSP_DIR="$(dirname "$0")/../Linux_for_Tegra"

if [ ! -d "$BSP_DIR" ]; then
    echo "Linux_for_Tegra not found. Extracting from container..."
    cd "$(dirname "$0")/.."
    sudo podman run --rm --entrypoint /bin/bash -v "$PWD:/out" \
        localhost/jetson-build-image-l4t36:latest \
        -c "cp -a /build/Linux_for_Tegra /out/"
fi

if ! lsusb | grep -qi "nvidia corp.*apx"; then
    echo "ERROR: Jetson not in recovery mode."
    echo "  1. Power off Jetson"
    echo "  2. Jumper FC REC <-> GND (J14 pins 9-10)"
    echo "  3. Connect USB-C to host"
    echo "  4. Power on"
    exit 1
fi

cd "$BSP_DIR"
sudo ./tools/kernel_flash/l4t_initrd_flash.sh \
    --external-device nvme0n1p1 \
    -c tools/kernel_flash/flash_l4t_external.xml \
    -p "-c bootloader/generic/cfg/flash_t234_qspi.xml" \
    --showlogs --network usb0 \
    jetson-orin-nano-devkit external
