#!/bin/bash
# F1TENTH workspace first-boot setup
# Runs on the real Jetson hardware on first boot.
# Auto-detects installed ROS distro (humble/jazzy/kilted).

set -e

FLAG=/var/lib/f1tenth-first-boot.done
if [ -f "$FLAG" ]; then
    exit 0
fi

# Detect ROS distro from /opt/ros/
ROS_DISTRO=""
for d in humble jazzy kilted; do
    if [ -f "/opt/ros/$d/setup.bash" ]; then
        ROS_DISTRO="$d"
        break
    fi
done

if [ -z "$ROS_DISTRO" ]; then
    echo "No ROS2 distro found in /opt/ros/"
    exit 1
fi

# Wait for network
for i in $(seq 1 60); do
    if ping -c 1 -W 2 packages.ros.org >/dev/null 2>&1; then
        break
    fi
    sleep 2
done

source "/opt/ros/$ROS_DISTRO/setup.bash"

cd /home/MIRU/f1tenth_ws

apt-get update
rosdep update --rosdistro "$ROS_DISTRO" || true
rosdep install --from-paths src -i -y --rosdistro "$ROS_DISTRO" || true

su - MIRU -s /bin/bash -c "
    source /opt/ros/$ROS_DISTRO/setup.bash &&
    cd ~/f1tenth_ws &&
    colcon build
"

touch "$FLAG"
