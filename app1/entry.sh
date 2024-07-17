#!/bin/sh

# List everything in /data which should be mounted to `/run/mount/`
echo "Everything in /data --> our external drive"
tree /data
# Idle forever to keep the container alive.
balena-idle

