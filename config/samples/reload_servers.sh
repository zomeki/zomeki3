#!/bin/sh

RELOAD_FLAG_FILE='/var/www/zomeki/tmp/reload_servers.txt'

if [ -e $RELOAD_FLAG_FILE ]; then
  systemctl reload nginx > /dev/null 2>&1
  rm -f $RELOAD_FLAG_FILE
fi
