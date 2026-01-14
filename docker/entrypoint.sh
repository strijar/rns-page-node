#!/bin/sh
set -e

# Fix permissions if they are wrong (e.g. volume mounts)
# We only do this if we are root
if [ "$(id -u)" = '0' ]; then
    chown -R app:app /app /home/app/.reticulum
fi

# If the first argument is an option (starts with a dash), prepend the app command
if [ "${1#-}" != "$1" ]; then
    set -- rns-page-node "$@"
fi

# If we are root, drop privileges and run the command
if [ "$(id -u)" = '0' ]; then
    exec su-exec app "$@"
else
    exec "$@"
fi
