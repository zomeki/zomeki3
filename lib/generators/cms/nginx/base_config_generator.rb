module Cms
  module Nginx
    class BaseConfigGenerator < Rails::Generators::Base
      source_root ::File.expand_path('../templates', __FILE__)

      def create_configs
        template 'nginx.conf.erb', 'config/nginx/nginx.conf'
        template 'rewrite.conf.erb', 'config/nginx/rewrite.conf'
        template 'servers_common.conf.erb', 'config/nginx/servers_common.conf'
      end
    end
  end
end
