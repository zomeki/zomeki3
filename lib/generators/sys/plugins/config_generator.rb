module Sys
  module Plugins
    class ConfigGenerator < Rails::Generators::Base
      source_root ::File.expand_path('../templates', __FILE__)

      def create_gemfile
        @plugins = enabled_plugins
        template 'Gemfile.erb', 'config/plugins/Gemfile' 
      end

      private

      def enabled_plugins
        Sys::Plugin.where(state: 'enabled').order(:name).all
      end
    end
  end
end
