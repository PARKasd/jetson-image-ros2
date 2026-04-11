#!/bin/bash
# Conditionally enable xorg dummy driver based on HDMI connection status.
# If a physical display is connected, remove the dummy conf so HDMI works.
# If headless, install the dummy conf so XRDP/NoMachine have a fallback.

set -e

DUMMY_SRC=/etc/X11/xorg-dummy.conf
DUMMY_DST=/etc/X11/xorg.conf.d/10-dummy.conf

connected=0
for status in /sys/class/drm/card*-HDMI*/status /sys/class/drm/card*-DP*/status; do
    [ -f "$status" ] || continue
    if [ "$(cat "$status")" = "connected" ]; then
        connected=1
        break
    fi
done

mkdir -p /etc/X11/xorg.conf.d

if [ "$connected" = "1" ]; then
    rm -f "$DUMMY_DST"
else
    cp "$DUMMY_SRC" "$DUMMY_DST"
fi
