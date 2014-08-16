require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CmsCMS
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = 'Tokyo'
    config.active_record.default_timezone = :local
    config.active_record.time_zone_aware_attributes = false

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.i18n.default_locale = :ja

    config.autoload_paths += %W(#{config.root}/lib)

    config.generators do |g|
      g.test_framework :rspec,
        fixtures: true,
        view_specs: false,
        helper_specs: false,
        routing_specs: false,
        controller_specs: true,
        request_specs: false
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
    end

    Dir::entries("#{Rails.root}/config/modules").each do |mod|
      next if mod =~ /^\./
      file = "#{Rails.root}/config/modules/#{mod}/locales/translation_ja.yml"
      config.i18n.load_path << file if FileTest.exist?(file)
    end

    config.action_view.sanitized_allowed_tags = ActionView::Base.sanitized_allowed_tags | %w(table caption tr th td iframe)
    config.action_view.sanitized_allowed_attributes = ActionView::Base.sanitized_allowed_attributes | %w(style class href src alt title colspan rowspan target id)
  end

  ADMIN_URL_PREFIX = '_system'
end
