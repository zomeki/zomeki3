#!/bin/bash
DONE_FLAG="/tmp/$0_done"

echo "#### Install nginx ####"
if [ -f $DONE_FLAG ]; then exit; fi
echo '-- PRESS ENTER KEY --'
read KEY

centos() {
  echo "It's CentOS!"

  firewall-cmd --add-service=http --zone=public

cat <<'EOF' > /etc/yum.repos.d/nginx.repo
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/7/$basearch/
gpgcheck=0
enabled=1
EOF

  yum -y install nginx
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
