#!/bin/bash
DONE_FLAG="/tmp/$0_done"

echo '#### Install ZOMEKI ####'
if [ -f $DONE_FLAG ]; then exit; fi
echo '-- PRESS ENTER KEY --'
read KEY

centos() {
  echo "It's CentOS!"

  if [ -d /var/www/zomeki ]; then
    echo 'ZOMEKI is already installed.'
    touch $DONE_FLAG
    exit
  fi

  id zomeki || useradd -m zomeki

  curl --silent --location https://rpm.nodesource.com/setup_4.x | bash -
  yum -y install libxml2-devel libxslt-devel openldap-devel nodejs patch

  rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
  yum -y install --enablerepo=remi ImageMagick-last-devel

  git clone https://github.com/zomeki/zomeki3.git /var/www/zomeki
  chown -R zomeki:zomeki /var/www/zomeki
  su - zomeki -c 'export LANG=ja_JP.UTF-8; cd /var/www/zomeki && bundle config build.pg --with-pg-config=/usr/pgsql-9.5/bin/pg_config'
  su - zomeki -c 'export LANG=ja_JP.UTF-8; cd /var/www/zomeki && bundle install --path vendor/bundle --without development test'

  cp /var/www/zomeki/config/samples/zomeki_logrotate /etc/logrotate.d/.

  cp /var/www/zomeki/config/samples/reload_servers.sh /root/. && chmod 755 /root/reload_servers.sh
  ROOT_CRON_TXT='/var/www/zomeki/config/samples/root_cron.txt'
  crontab -l > $ROOT_CRON_TXT
  grep -s reload_servers.sh $ROOT_CRON_TXT || echo '0,30 * * * * /root/reload_servers.sh' >> $ROOT_CRON_TXT
  crontab $ROOT_CRON_TXT

  cp /var/www/zomeki/config/samples/unicorn /etc/init.d/.
  chmod a+x /etc/init.d/unicorn
  chkconfig unicorn on
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
