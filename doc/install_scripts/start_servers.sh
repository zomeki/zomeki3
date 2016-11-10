#!/bin/bash
DONE_FLAG="/tmp/$0_done"

echo '#### Start servers ####'
if [ -f $DONE_FLAG ]; then exit; fi
echo '-- PRESS ENTER KEY --'
read KEY

centos() {
  echo "It's CentOS!"

  systemctl start postgresql-9.5 && systemctl enable postgresql-9.5
  systemctl start nginx && systemctl enable nginx
  su - zomeki -c 'export LANG=ja_JP.UTF-8; cd /var/www/zomeki && bundle exec unicorn_rails -c config/unicorn/production.rb -E production -D'

  cp /var/www/zomeki/config/samples/unicorn /etc/init.d/.
  chmod a+x /etc/init.d/unicorn
  chkconfig unicorn on

  su - zomeki -c 'export LANG=ja_JP.UTF-8; cd /var/www/zomeki && bundle exec rake delayed_job:start RAILS_ENV=production'

  cp /var/www/zomeki/config/samples/delayed_job /etc/init.d/.
  chmod a+x /etc/init.d/delayed_job
  chkconfig delayed_job on

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
