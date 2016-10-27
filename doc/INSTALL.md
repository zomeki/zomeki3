# ZOMEKI インストールマニュアル

## 1.想定環境

### システム

* OS: CentOS 7.2
* Webサーバ: nginx 1.10
* Appサーバ: unicorn 5.1
* Database: PostgreSQL 9.5
* Ruby: 2.3
* Rails: 5.0

### 設定

* ホスト名: zomeki.example.com

## 2.作業ユーザの変更

rootユーザに変更します。

    $ su -

## 3.SELinuxの変更

SELinuxを変更します。

    # setenforce 0

    # vi /etc/sysconfig/selinux
```
SELINUX=permissive    # 変更
```

*※セキュリティ設定は環境に応じて適切に設定してください。*

## 4.事前準備

作業に必要なパッケージをインストールします。

    # yum -y install git epel-release

## 5.Rubyのインストール

必要なパッケージをインストールします。

    # yum -y install gcc-c++ libffi-devel libyaml-devel make openssl-devel readline-devel zlib-devel bzip2

rbenvをインストールします。

    # git clone git://github.com/sstephenson/rbenv.git /usr/local/rbenv
    # git clone git://github.com/sstephenson/ruby-build.git /usr/local/rbenv/plugins/ruby-build

    # echo 'export RBENV_ROOT="/usr/local/rbenv"' >> /etc/profile.d/rbenv.sh
    # echo 'export PATH="${RBENV_ROOT}/bin:${PATH}"' >> /etc/profile.d/rbenv.sh
    # echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh
    # source /etc/profile.d/rbenv.sh

rubyをインストールします。

    # rbenv install 2.3.1
    # rbenv global 2.3.1
    # rbenv rehash
    # ruby -v

bundlerをインストールします。

    # gem install bundler

## 6.nginxのインストール

外部からhttpでアクセス可能にします。  
※ファイアーウォール設定は環境に応じて適切に設定してください。

    # firewall-cmd --add-service=http --zone=public

yumリポジトリに追加します。

    # vi /etc/yum.repos.d/nginx.repo
```
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/7/$basearch/
gpgcheck=0
enabled=1
```

インストールします。

    # yum -y install nginx

## 7.PostgreSQLのインストール

yumリポジトリに追加します。

    # yum -y install http://yum.postgresql.org/9.5/redhat/rhel-7-x86_64/pgdg-centos95-9.5-2.noarch.rpm

インストールします。

    # yum -y install postgresql95-server postgresql95-contrib postgresql95-devel

データベースを初期化します。

    # /usr/pgsql-9.5/bin/postgresql95-setup initdb

ユーザ認証方法を変更します。

    # vim /var/lib/pgsql/9.5/data/pg_hba.conf
```
host    all             all             127.0.0.1/32            md5
```

データベースを起動します。

    # systemctl start postgresql-9.5

ZOMEKI用のユーザを作成します。
※パスワードは任意の文字列を設定してください。（ここでは「zomekipass」とします。）

    # su - postgres -c "psql -c \"CREATE USER zomeki WITH CREATEDB ENCRYPTED PASSWORD 'zomekipass';\""

## 8.ZOMEKIのインストール

専用ユーザを作成します。

    # useradd -m zomeki

必要なパッケージをインストールします。

    # curl --silent --location https://rpm.nodesource.com/setup_4.x | bash -
    # yum -y install libxml2-devel libxslt-devel openldap-devel nodejs patch

    # rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
    # yum -y install --enablerepo=remi ImageMagick-last-devel

ZOMEKIをインストールします。

    # git clone https://github.com/zomeki/zomeki3.git /var/www/zomeki
    # chown -R zomeki:zomeki /var/www/zomeki
    # su - zomeki -c 'export LANG=ja_JP.UTF-8; cd /var/www/zomeki && bundle config build.pg --with-pg-config=/usr/pgsql-9.5/bin/pg_config'
    # su - zomeki -c 'export LANG=ja_JP.UTF-8; cd /var/www/zomeki && bundle install --path vendor/bundle --without development test'

    # cp /var/www/zomeki/config/samples/zomeki_logrotate /etc/logrotate.d/.

    # cp /var/www/zomeki/config/samples/reload_servers.sh /root/. && chmod 755 /root/reload_servers.sh
    # ROOT_CRON_TXT='/var/www/zomeki/config/samples/root_cron.txt'
    # crontab -l > $ROOT_CRON_TXT
    # grep -s reload_servers.sh $ROOT_CRON_TXT || echo '0,30 * * * * /root/reload_servers.sh' >> $ROOT_CRON_TXT
    # crontab $ROOT_CRON_TXT

## 9.ZOMEKIの設定

設定ファイルのサンプルをコピーして変更します。

    # cp -p /var/www/zomeki/config/core.yml.sample /var/www/zomeki/config/core.yml
    # vi /var/www/zomeki/config/core.yml
```
uri: http://zomeki.example.com/    # すべて変更
```

設定ファイルのサンプルをコピーします。

    # cp -p /var/www/zomeki/config/sns_apps.yml.sample /var/www/zomeki/config/sns_apps.yml

シークレットキーを設定します。

    # su - zomeki -c 'export LANG=ja_JP.UTF-8; cd /var/www/zomeki && bundle exec rake secret RAILS_ENV=production'
      (出力されたシークレットキーをコピーします)
    # vi /var/www/zomeki/config/secrets.yml
    ---
    production:
      secret_key_base: (コピーしたシークレットキーを貼り付けます)
    ---

必要なデータベースを作ります。

    # su - zomeki -c 'export LANG=ja_JP.UTF-8; cd /var/www/zomeki && bundle exec rake db:setup RAILS_ENV=production'

設定ファイルを作成してリンクを作成します。

    # su - zomeki -c 'export LANG=ja_JP.UTF-8; cd /var/www/zomeki && bundle exec rake zomeki:configure RAILS_ENV=production'
    # ln -s /var/www/zomeki/config/nginx/nginx.conf /etc/nginx/conf.d/zomeki.conf

## 10.ふりがな・読み上げ機能のインストール

必要なパッケージをインストールします。

    # yum -y install sox

hts_engine APIをインストールします。

    # cd /usr/local/src
    # curl -fsSLO http://downloads.sourceforge.net/hts-engine/hts_engine_API-1.09.tar.gz
    # tar zxf hts_engine_API-1.09.tar.gz && cd hts_engine_API-1.09 && ./configure CFLAGS='-O3 -march=native -funroll-loops' && make && make install

Open JTalkをインストールします。

    # cd /usr/local/src
    # curl -fsSLO http://downloads.sourceforge.net/open-jtalk/open_jtalk-1.08.tar.gz
    # tar zxf open_jtalk-1.08.tar.gz && cd open_jtalk-1.08
    # sed -i 's/#define MAXBUFLEN 1024/#define MAXBUFLEN 10240/' bin/open_jtalk.c
    # ./configure --with-charset=UTF-8 CFLAGS='-O3 -march=native -funroll-loops' CXXFLAGS='-O3 -march=native -funroll-loops' && make && make install

Dictionaryをインストールします。

    # cd /usr/local/src
    # curl -fsSLO http://downloads.sourceforge.net/open-jtalk/open_jtalk_dic_utf_8-1.08.tar.gz
    # tar zxf open_jtalk_dic_utf_8-1.08.tar.gz
    # mkdir /usr/local/share/open_jtalk && mv open_jtalk_dic_utf_8-1.08 /usr/local/share/open_jtalk/dic

LAMEをインストールします。

    # cd /usr/local/src
    # curl -fsSLO http://jaist.dl.sourceforge.net/project/lame/lame/3.99/lame-3.99.5.tar.gz
    # tar zxf lame-3.99.5.tar.gz && cd lame-3.99.5 && ./configure && make && make install

MeCabをインストールします。

    # cd /usr/local/src
    # curl -fsSL 'https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7cENtOXlicTFaRUE' -o mecab-0.996.tar.gz
    # tar zxf mecab-0.996.tar.gz && cd mecab-0.996 && ./configure --enable-utf8-only && make && make install

MeCab-IPAdicをインストールします。

    # cd /usr/local/src
    # curl -fsSL 'https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7MWVlSDBCSXZMTXM' -o mecab-ipadic-2.7.0-20070801.tar.gz
    # tar zxf mecab-ipadic-2.7.0-20070801.tar.gz && cd mecab-ipadic-2.7.0-20070801 && ./configure --with-charset=utf8 && make && make install

MeCab-Rubyをインストールします。

    # cd /usr/local/src
    # curl -fsSL 'https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7VUNlczBWVDZJbE0' -o mecab-ruby-0.996.tar.gz
    # tar zxf mecab-ruby-0.996.tar.gz && cd mecab-ruby-0.996 && ruby extconf.rb && make && make install

libmecabのパスを設定します。

    # echo '/usr/local/lib' >> /etc/ld.so.conf.d/usrlocal.conf
    # sudo ldconfig
    # ldconfig -p | grep "/usr/local/lib"

## 11.サーバーの起動

postgresqlを起動します。

    # systemctl start postgresql-9.5 && systemctl enable postgresql-9.5

nginxを起動します。

    # systemctl start nginx && systemctl enable nginx

unicornを起動します。

    # su - zomeki -c 'export LANG=ja_JP.UTF-8; cd /var/www/zomeki && bundle exec unicorn_rails -c config/unicorn/production.rb -E production -D'

delayed_jobを起動します。

    # su - zomeki -c 'export LANG=ja_JP.UTF-8; cd /var/www/zomeki && bundle exec rake delayed_job:start RAILS_ENV=production'

## 12.定期実行処理 の設定

ユーザzomekiのcronに処理を追加します。

    # su - zomeki -c 'export LANG=ja_JP.UTF-8; cd /var/www/zomeki && bundle exec whenever --update-crontab'

## 13.動作確認

インストールが完了しました。

* 公開画面: http://zomeki.example.com/
* 管理画面: http://zomeki.example.com/_system

* 管理者（システム管理者）
  - ユーザID: zomeki
  - パスワード: zomeki
