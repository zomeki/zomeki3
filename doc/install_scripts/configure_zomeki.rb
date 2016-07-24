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

  sns_apps_yml = '/var/www/zomeki/config/sns_apps.yml'
  FileUtils.copy("#{sns_apps_yml}.sample", sns_apps_yml, preserve: true)

  system "su - zomeki -c 'export LANG=ja_JP.UTF-8; cd /var/www/zomeki && bundle exec rake db:setup RAILS_ENV=production'"

  system "su - zomeki -c 'export LANG=ja_JP.UTF-8; cd /var/www/zomeki && bundle exec rake zomeki:configure RAILS_ENV=production'"
  system 'ln -s /var/www/zomeki/config/nginx/nginx.conf /etc/nginx/conf.d/zomeki.conf'
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
