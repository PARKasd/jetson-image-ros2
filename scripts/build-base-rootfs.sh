#!/usr/bin/env bash

# Author Badr @pythops

set -e

echo "Building base rootfs"

if [ "$1" != "24.04" ] && [ "$1" != "22.04" ] && [ "$1" != "20.04" ]; then
  echo "Error: Unknow version of ubuntu. The supported versions are: 20.04, 22.04, 24.04"
  exit 1
fi

case $1 in
"20.04")
  podman build \
    --jobs=4 \
    --arch=arm64 \
    --network=host \
    -f Containerfile.rootfs.20_04 \
    -t jetson-rootfs
  ;;

"22.04")
  podman build \
    --jobs=4 \
    --arch=arm64 \
    --network=host \
    -f Containerfile.rootfs.22_04 \
    -t jetson-rootfs
  ;;

"24.04")
  podman build \
    --jobs=4 \
    --arch=arm64 \
    --network=host \
    -f Containerfile.rootfs.24_04 \
    -t jetson-rootfs
  ;;

*)
  exit 1
  ;;
esac

sudo rm -rf base rootfs
podman save --format docker-dir -o base jetson-rootfs

sudo mkdir rootfs

for layer in $(jq -r '.layers[].digest' base/manifest.json | awk -F ':' '{print $2}'); do
  sudo tar xpf base/"$layer" --numeric-owner --directory=rootfs
done

sudo rm -rf rootfs/root/.bash_history

sudo rm -rf base

echo "Rootfs created in rootfs directory"
