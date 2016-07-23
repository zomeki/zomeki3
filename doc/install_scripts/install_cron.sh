#!/bin/bash
DONE_FLAG="/tmp/$0_done"

echo '#### Install cron ####'
if [ -f $DONE_FLAG ]; then exit; fi
echo '-- PRESS ENTER KEY --'
read KEY

centos() {
  echo "It's CentOS!"

  su - zomeki -c 'export LANG=ja_JP.UTF-8; cd /var/share/zomeki && bundle exec whenever --update-crontab'
}

others() {
  echo 'This OS is not supported.'
}

if [ -f /etc/centos-release ]; then
  centos
elif [ -f /etc/lsb-release ]; then
  if grep -qs Ubuntu /etc/lsb-release; then
    echo 'Ubuntu is not yet supported.'
  else
    others
  fi
else
  others
fi

touch $DONE_FLAG
