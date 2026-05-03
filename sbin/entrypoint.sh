#!/usr/bin/env sh

fix_perm() {
    for dir in "$@"; do
        find "$dir" \
            \( ! -user 1000 -type d -exec chown 1000:1000 {} \; -exec chmod 2775 {} \; -exec echo fix_perm: {} \; \) \
            -o \
            \( ! -user 1000 -type f -exec chown 1000:1000 {} \; -exec chmod 0664 {} \; -exec echo fix_perm: {} \; \)
    done
}

echo 'start'
fix_perm "/wavelog/config/" "/wavelog/uploads/" "/wavelog/userdata/" "/wavelog/updates/"


echo "Starting 'lighttpd'..."
lighttpd -D -f "$LIGHTTPD_CONF" &

P1=$!

echo "Starting 'php-fpm84'..."
php-fpm84 -F &

P2=$!

trap "echo 'Stopping...'; kill $P1 $P2; wait; exit 0" TERM INT

wait -n

echo "One process exited. Shutting down All..."
kill $P1 $P2

wait
echo 'exit'
