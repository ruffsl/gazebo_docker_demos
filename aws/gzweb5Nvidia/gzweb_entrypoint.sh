#!/bin/bash
set -e


# setup ros environment
echo GAZEBO_MASTER_URI=$GAZEBO_MASTER_URI
/root/gzweb/./start_gzweb.sh

exec "$@"
