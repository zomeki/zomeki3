module Cms
  module Apache
    class BaseConfigGenerator < Rails::Generators::Base
      source_root ::File.expand_path('../templates', __FILE__)

      def create_configs
        template 'apache.conf.erb', 'config/apache/apache.conf'
        template 'rewrite_base.conf.erb', 'config/apache/rewrite_base.conf'
        template 'rewrite_ssl.conf.erb', 'config/apache/rewrite_ssl.conf'
      end
    end
  end
end
