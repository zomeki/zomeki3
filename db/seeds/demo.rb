# encoding: utf-8

Rails.application.eager_load!

# delete publisher callbacks
ApplicationRecord.descendants.each do |model|
  callbacks = model._save_callbacks.select { |c| c.filter.is_a?(PublisherCallbacks) }
  callbacks.each { |c| model._save_callbacks.delete(c) }
end

begin
  load "#{Rails.root}/db/seeds/reset/zomeki.rb"
  @create_base = true
  core_uri   = Util::Config.load :core, :uri
  core_title = Util::Config.load :core, :title
  map_key    = Util::Config.load :core, :map_key

  @site = Cms::Site.create!(
    :state              => 'public',
    :name               => core_title,
    :full_uri           => core_uri,
    :google_map_api_key => map_key,
    :portal_group_state => 'visible'
  )

  load "#{Rails.root}/db/seeds/initialize/base.rb"
  load "#{Rails.root}/db/seeds/demo/base.rb"
  puts "-- seed/demo success."
rescue => e
  puts "----------"
  puts e.to_s
  puts e.backtrace.join("\n")
end
