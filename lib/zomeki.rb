module Zomeki
  def self.version
    "3.0.13 build-13"
  end

  def self.default_config
    { "application" => {
      "sys.crypt_pass"                => "cms",
      "sys.recognizers_include_admin" => false,
      "sys.auto_link_check"           => true,
      "cms.publish_more_pages"        => 0
    }}
  end

  def self.config
    $cms_config ||= {}
    Zomeki::Config
  end

  class Zomeki::Config
    def self.application
      return $cms_config[:application] if $cms_config[:application]

      config = Zomeki.default_config["application"]
      file   = "#{Rails.root}/config/application.yml"
      if ::File.exist?(file)
        yml = YAML.load_file(file)
        yml.each do |mod, values|
          values.each do |key, value|
            config["#{mod}.#{key}"] = value unless value.nil?
          end if values
        end if yml
      end
      $cms_config[:application] = config
    end
  end
end
