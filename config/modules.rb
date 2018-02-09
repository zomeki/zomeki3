ActiveSupport.on_load :after_initialize do
  # Modules
  Dir[Rails.root.join('config/modules/**/module.rb')].each do |file|
    load file
  end

  # Engines
  Rails.application.config.x.engines.each do |engine|
    gem_name = engine.name.chomp('::Engine').underscore.tr('/', '-')
    if (spec = Gem.loaded_specs[gem_name])
      Dir["#{spec.full_gem_path}/config/modules/**/module.rb"].each do |file|
        load file
      end
    end
  end
end
