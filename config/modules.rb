ActiveSupport.on_load :after_initialize do
  # Modules
  Dir[Rails.root.join('config/modules/**/module.rb')].each do |file|
    load file
  end

  # Engines
  Rails.application.config.x.engines.each do |engine|
    Dir["#{engine.root}/config/modules/**/module.rb"].each do |file|
      load file
    end
  end
end
