#!/usr/bin/env bash
# Full rebuild + reflash pipeline for Jetson Orin Nano (L4T 36).
# Leave Jetson in recovery mode before running (FC REC <-> GND jumper + USB-C).
# Usage: build-and-flash.sh [22.04|24.04]  (default: 22.04)

set -e

UBUNTU_VERSION="${1:-22.04}"
if [ "$UBUNTU_VERSION" != "22.04" ] && [ "$UBUNTU_VERSION" != "24.04" ]; then
    echo "Usage: $0 [22.04|24.04]"
    exit 1
fi

REPO="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO"

echo "==> [1/4] Building base rootfs ($UBUNTU_VERSION)"
sudo ./scripts/build-base-rootfs.sh "$UBUNTU_VERSION"

echo "==> [2/4] Building Jetson image (l4t36)"
sudo ./scripts/build-jetson-image.sh -b jetson-orin-nano -d USB -l 36 || true

echo "==> [3/4] Extracting Linux_for_Tegra from container"
sudo rm -rf Linux_for_Tegra
sudo podman run --rm --entrypoint /bin/bash \
    -v "$PWD:/out" \
    localhost/jetson-build-image-l4t36:latest \
    -c "cp -a /build/Linux_for_Tegra /out/"

echo "==> [4/4] Waiting for Jetson in recovery mode"
while ! lsusb | grep -qi "nvidia corp.*apx"; do
    echo "    Jetson not detected. Put it in recovery mode (FC REC jumper + USB-C + power)."
    sleep 10
done

echo "==> Flashing"
cd "$REPO/Linux_for_Tegra"
sudo ./tools/kernel_flash/l4t_initrd_flash.sh \
    --external-device nvme0n1p1 \
    -c tools/kernel_flash/flash_l4t_external.xml \
    -p "-c bootloader/generic/cfg/flash_t234_qspi.xml" \
    --showlogs --network usb0 \
    jetson-orin-nano-devkit external

echo "==> Done. Remove recovery jumper and reboot Jetson."
