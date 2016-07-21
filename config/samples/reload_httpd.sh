#!/bin/sh

RELOAD_FLAG_FILE='/var/www/zomeki/tmp/reload_virtual_hosts.txt'

if [ -e $RELOAD_FLAG_FILE ]; then
  systemctl reload httpd > /dev/null 2>&1
  rm -f $RELOAD_FLAG_FILE
fi
