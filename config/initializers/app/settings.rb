def load_settings(filename)
  file = Rails.root.join(filename)
  YAML::load(ERB.new(File.read(file)).result)[Rails.env].deep_symbolize_keys if File.exist?(file)
end

Rails.application.config.action_mailer.smtp_settings = load_settings('config/smtp.yml')
