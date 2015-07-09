#!/bin/bash
set -e

# setup ros environment
source "/usr/share/gazebo/setup.sh"
export QT_X11_NO_MITSHM=1

exec "$@"
