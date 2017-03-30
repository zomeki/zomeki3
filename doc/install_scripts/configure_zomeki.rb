#!/usr/bin/env ruby
DONE_FLAG = "/tmp/#{$0}_done"

puts '#### Configure ZOMEKI ####'
exit if File.exist?(DONE_FLAG)
puts '-- PRESS ENTER KEY --'
gets

require 'fileutils'
require 'yaml/store'

def centos
  puts "It's CentOS!"

  core_yml = '/var/www/zomeki/config/core.yml'
  FileUtils.copy("#{core_yml}.sample", core_yml, preserve: true)

  db = YAML::Store.new(core_yml)
  db.transaction do
    db['production']['uri'] = "http://#{`hostname`.chomp}/"
  end

  system "su - zomeki -c 'export LANG=ja_JP.UTF-8; cd /var/www/zomeki && bundle exec rake db:setup RAILS_ENV=production'"
  system "su - zomeki -c 'export LANG=ja_JP.UTF-8; cd /var/www/zomeki && bundle exec rake db:seed:demo RAILS_ENV=production'"

  system "su - zomeki -c 'export LANG=ja_JP.UTF-8; cd /var/www/zomeki && bundle exec rake zomeki:configure RAILS_ENV=production'"
  system 'ln -s /var/www/zomeki/config/nginx/nginx.conf /etc/nginx/conf.d/zomeki.conf'
  system 'mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.org'

  secret = `su - zomeki -c 'export LANG=ja_JP.UTF-8; cd /var/www/zomeki && bundle exec rake secret RAILS_ENV=production'`
  File.open '/var/www/zomeki/config/secrets.yml', File::RDWR do |f|
    f.flock File::LOCK_EX

    conf = f.read
    conf.sub!('<%= ENV["SECRET_KEY_BASE"] %>', secret)

    f.rewind
    f.write conf
    f.flush
    f.truncate f.pos

    f.flock File::LOCK_UN
  end
end

def others
  puts 'This OS is not supported.'
end

if __FILE__ == $0
  if File.exist? '/etc/centos-release'
    centos
  elsif File.exist? '/etc/lsb-release'
    unless `grep -s Ubuntu /etc/lsb-release`.empty?
      puts 'Ubuntu is not yet supported.'
    else
      others
    end
  else
    others
  end

  system "touch #{DONE_FLAG}"
end
