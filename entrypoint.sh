#!/bin/sh

if [ ! -f /etc/logrotate.conf ]; then
    echo "/etc/logrotate.conf not found"
    exit 1
fi

echo "$CRON_SCHEDULE /usr/sbin/logrotate /etc/logrotate.conf" | crontab -

exec tini $@
