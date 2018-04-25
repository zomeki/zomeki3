module Cms
  module Apache
    class SiteConfigGenerator < Rails::Generators::Base
      source_root ::File.expand_path('../templates', __FILE__)

      class_option :site_id, desc: "Site ID"

      def create_configs
        load_sites.each do |site|
          @site = site
          paths = conf_paths(@site.id)

          template 'virtual_hosts/virtual_host.conf.erb', paths[:public]
          if @site.full_uri =~ /^https:/
            template 'virtual_hosts/virtual_host.conf.erb', paths[:public_ssl], ssl: true
          else
            remove_file paths[:public_ssl]
          end

          if @site.admin_full_uri.present?
            template 'virtual_hosts/virtual_host.conf.erb', paths[:admin], admin: true
            if @site.admin_full_uri =~ /^https:/
              template 'virtual_hosts/virtual_host.conf.erb', paths[:admin_ssl], admin: true, ssl: true
            else
              remove_file paths[:admin_ssl]
            end
          else
            remove_file paths[:admin]
            remove_file paths[:admin_ssl]
          end
        end
      end

      def delete_configs
        deleted_site_ids = conf_site_ids - load_sites.pluck(:id)
        deleted_site_ids.each do |site_id|
          conf_paths(site_id).values.each do |path|
            remove_file path
          end
        end
      end

      private

      def remove_file(path)
        super if ::File.exist?(path)
      end

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

      def conf_paths(site_id)
        {
          public:     "config/apache/virtual_hosts/site_#{format('%04d', site_id)}.conf",
          public_ssl: "config/apache/virtual_hosts/ssl_site_#{format('%04d', site_id)}.conf",
          admin:      "config/apache/admin_virtual_hosts/site_#{format('%04d', site_id)}.conf",
          admin_ssl:  "config/apache/admin_virtual_hosts/ssl_site_#{format('%04d', site_id)}.conf"
        }
      end
    end
  end
end
