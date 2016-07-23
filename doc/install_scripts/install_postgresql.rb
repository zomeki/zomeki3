#!/usr/bin/env ruby
DONE_FLAG = "/tmp/#{$0}_done"

puts '#### Install PostgreSQL ####'
exit if File.exist?(DONE_FLAG)
puts '-- PRESS ENTER KEY --'
gets

require 'fileutils'

def centos
  puts "It's CentOS!"

  system 'yum -y install http://yum.postgresql.org/9.5/redhat/rhel-7-x86_64/pgdg-centos95-9.5-2.noarch.rpm'
  system 'yum -y install postgresql95-server postgresql95-contrib postgresql95-devel'

  system '/usr/pgsql-9.5/bin/postgresql95-setup initdb'

  pg_hba_conf = '/var/lib/pgsql/9.5/data/pg_hba.conf'
  FileUtils.copy pg_hba_conf, "#{pg_hba_conf}.#{Time.now.strftime('%Y%m%d%H%M')}", preserve: true
  File.open pg_hba_conf, File::RDWR do |f|
    f.flock File::LOCK_EX

    conf = f.read

    f.rewind
#    f.write conf.sub(/^#ServerName .*$/) {|m| "#{m}\nServerName #{`hostname`.chomp}" }
    f.flush
    f.truncate(f.pos)

    f.flock File::LOCK_UN
  end

#  system 'systemctl start postgresql-9.5'

  psql_c = %q!psql -c \"CREATE USER zomeki WITH PASSWORD 'zomekipass';\"!
#  system %Q!su - postgres -c "#{psql_c}"!
  puts %Q!su - postgres -c "#{psql_c}"!
end

def others
  puts 'This OS is not supported.'
end

if __FILE__ == $0
  if File.exist? '/etc/centos-release'
    centos
  elsif File.exist? '/etc/lsb-release'
    unless `grep -s Ubuntu /etc/lsb-release`.empty?
      puts 'Ubuntu will be supported shortly.'
    else
      others
    end
  else
    others
  end

  system "touch #{DONE_FLAG}"
end
