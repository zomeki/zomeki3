module Cms
  module Nginx
    class SiteConfigGenerator < Rails::Generators::Base
      source_root ::File.expand_path('../templates', __FILE__)

      class_option :site_id, desc: "Site ID"

      def create_configs
        load_sites.each do |site|
          @site = site
          template 'servers/server.conf.erb', @site.nginx_config_path

          if @site.admin_full_uri.present?
            template 'servers/admin_server.conf.erb', @site.nginx_admin_config_path
          else
            remove_file site.nginx_admin_config_path
          end
        end
      end

      def delete_configs
        deleted_site_ids = conf_site_ids - load_sites.pluck(:id)
        deleted_site_ids.each do |site_id|
          remove_file "config/nginx/servers/site_#{'%04d' % site_id}.conf"
          remove_file "config/nginx/admin_servers/site_#{'%04d' % site_id}.conf"
        end
      end

      private

      def load_sites
        sites = Cms::Site.order(:id)
        sites.where!(id: options[:site_id]) if options[:site_id].present?
        sites
      end

      def conf_site_ids
        if options[:site_id].present?
          [options[:site_id].to_i]
        else
          Dir.glob('config/apache/virtual_hosts/*.conf').map { |file| file.scan(/site_(\d+)\.conf/).flatten.first.to_i }
        end
      end
    end
  end
end
