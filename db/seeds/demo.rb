# encoding: utf-8

# encoding: utf-8

begin
  load "#{Rails.root}/db/seeds/reset/zomeki.rb"
  load "#{Rails.root}/db/seeds/base.rb"
  load "#{Rails.root}/db/seeds/demo/base.rb"
  puts "-- seed/demo success."
rescue => e
  puts "----------"
  puts e.to_s
  puts e.backtrace.join("\n")
end
