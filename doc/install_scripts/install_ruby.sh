#!/bin/bash
DONE_FLAG="/tmp/$0_done"

RUBY_VERSION='ruby-2.3.1'
RUBY_FILENAME="$RUBY_VERSION.tar.bz2"
RUBY_SOURCE_URL="http://cache.ruby-lang.org/pub/ruby/2.3/$RUBY_FILENAME"

echo "#### Install $RUBY_VERSION ####"
if [ -f $DONE_FLAG ]; then exit; fi
echo '-- PRESS ENTER KEY --'
read KEY

centos() {
  echo "It's CentOS!"

  yum -y install gcc-c++ libffi-devel libyaml-devel make openssl-devel readline-devel zlib-devel

  cd /usr/local/src
  rm -rf $RUBY_FILENAME $RUBY_VERSION
  curl -fsSLO $RUBY_SOURCE_URL
  tar jxf $RUBY_FILENAME && cd $RUBY_VERSION && ./configure && make && make install

  gem install bundler
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
