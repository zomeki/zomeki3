# encoding: utf-8

# encoding: utf-8

begin
  settings = YAML.load_file("#{Rails.root}/config/seed.yml")
  if settings
    core_uri   = settings['site']['uri']
    core_title = settings['site']['title']
    map_key    = settings['site']['map_key']

    @code_prefix = settings['site']['prefix'] || "#{Cms::Site.all.count + 1}_"
    @create_base = false
    @site = Cms::Site.create(
      :state              => 'public',
      :name               => core_title,
      :full_uri           => core_uri,
      :google_map_api_key => map_key,
      :portal_group_state => 'visible'
    )

    if @site.save
      load "#{Rails.root}/db/seeds/initialize/base.rb"
      load "#{Rails.root}/db/seeds/demo/base.rb"
      puts "-- seed/site success."
    else
      puts "-- seed/site failed."
    end
  end

rescue => e
  puts "-- seed/demo failed."
  puts e.to_s
  puts $@
  #puts e.backtrace.join("\n")
end
