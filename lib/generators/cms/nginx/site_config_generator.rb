module Cms
  module Nginx
    class SiteConfigGenerator < Rails::Generators::Base
      source_root ::File.expand_path('../templates', __FILE__)

      class_option :site_id, desc: "Site ID"

      def create_configs
        load_sites.each do |site|
          @site = site
          @locations = Cms::Nginx::LocationBuilder.new(@site).build
          paths = conf_paths(@site.id)

          template 'servers/server.conf.erb', paths[:public]
          if @site.full_uri =~ /^https:/
            template 'servers/server.conf.erb', paths[:public_ssl], ssl: true
          else
            remove_file paths[:public_ssl]
          end

          if @site.admin_full_uri.present?
            template 'servers/server.conf.erb', paths[:admin], admin: true
            if @site.admin_full_uri =~ /^https:/
              template 'servers/server.conf.erb', paths[:admin_ssl], admin: true, ssl: true
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
        sites = Cms::Site.where(state: 'public').order(:id)
        sites.where!(id: options[:site_id]) if options[:site_id].present?
        sites
      end

      def conf_site_ids
        if options[:site_id].present?
          [options[:site_id].to_i]
        else
          Dir.glob('config/nginx/servers/site_*.conf').map { |file| file.scan(/site_(\d+)\.conf/).flatten.first.to_i }
        end
      end

      def conf_paths(site_id)
        {
          public:     "config/nginx/servers/site_#{format('%04d', site_id)}.conf",
          public_ssl: "config/nginx/servers/ssl_site_#{format('%04d', site_id)}.conf",
          admin:      "config/nginx/admin_servers/site_#{format('%04d', site_id)}.conf",
          admin_ssl:  "config/nginx/admin_servers/ssl_site_#{format('%04d', site_id)}.conf"
        }
      end
    end

    class Location
      include ActiveModel::Model

      attr_accessor :site
      attr_accessor :path, :try_files, :htpasswd_path, :ips

      def initialize(atts = {})
        self.ips = []
        super
      end
    end

    class LocationBuilder
      def initialize(site)
        @site = site
        @try_files = %w($uri $uri/index.html)
      end

      def build
        locations =  make_system_locations
        locations += make_public_locations
        locations += make_public_error_locations if @site.smart_phone_layout_same_as_pc?
        locations += make_public_default_locations

        append_request_uri_for_smartphone(locations) if @site.smart_phone_layout_same_as_pc?

        locations
      end

      private

      def load_dynamic_dirs
        @site.nodes.public_state.dynamic_models
             .map { |node| node.public_uri.chomp('/') }
      end

      def load_access_controls_for_directory
        return {} unless @site.use_access_control?
        @site.access_controls.where(state: 'enabled', target_type: 'directory')
                             .reorder(:target_location)
                             .group_by { |c| "/#{c.target_location}".chomp('/') }
      end

      def make_system_locations
        locations = [Location.new(path: "/#{ZomekiCMS::ADMIN_URL_PREFIX}", try_files: @try_files + ['@proxy']),
                     Location.new(path: "/_preview", try_files: @try_files + ['@proxy'])]

        if @site.use_access_control?
          controls = @site.access_controls.where(state: 'enabled', target_type: '_system').order(:id)
          set_control_options(locations, controls, "#{@site.basic_auth_htpasswd_path}_system")
        end

        locations
      end

      def make_public_locations
        dynamic_dirs = load_dynamic_dirs
        access_controls_by_dir = load_access_controls_for_directory

        locations = []

        dirs = (dynamic_dirs + access_controls_by_dir.keys).uniq.sort_by { |d| d.count('/') }.reverse
        dirs.each do |dir|
          proxy = dir.in?(dynamic_dirs) ? '@dynamic' : '@proxy'
          dir_locations = [Location.new(path: "/_smartphone#{dir}", try_files: @try_files + [proxy]),
                           Location.new(path: "/_mobile#{dir}", try_files: @try_files + ['@dynamic']),
                           Location.new(path: dir, try_files: @try_files + [proxy])]

          if @site.use_access_control?
            controls = access_controls_by_dir[dir] || @site.access_controls.where(state: 'enabled', target_type: 'all').order(:id)
            htpasswd_path = @site.basic_auth_htpasswd_path
            htpasswd_path += "_#{dir.gsub(%r{^/}, '').gsub('/', '_')}" if controls.any?(&:target_type_directory?)
            set_control_options(dir_locations, controls, htpasswd_path)
          end

          locations += dir_locations
        end

        locations
      end

      def make_public_error_locations
        [Location.new(path: '/_smartphone/404.html', try_files: ['/404.html', '@proxy'])]
      end

      def make_public_default_locations
        locations = [Location.new(path: '/_smartphone', try_files: @try_files + ['@proxy']),
                     Location.new(path: '/_mobile', try_files: @try_files + ['@dynamic']),
                     Location.new(path: '/', try_files: @try_files + ['@proxy'])]

        if @site.use_access_control?
          controls = @site.access_controls.where(state: 'enabled', target_type: 'all').order(:id)
          set_control_options(locations, controls, @site.basic_auth_htpasswd_path)
        end

        locations
      end

      def append_request_uri_for_smartphone(locations)
        locations.each do |location|
          if location.path =~ %r{/_smartphone} &&
             location.try_files.include?('@proxy') &&
             !location.try_files.include?('/404.html')
            location.try_files = %w($request_uri $request_uri/index.html) + location.try_files
          end
        end
      end

      def set_control_options(locations, controls, htpasswd_path)
        return if locations.blank? || controls.blank?

        controls.each do |control|
          locations.each do |location|
            case control.ip_order
            when 'allow'
              location.ips += control.ips.map { |ip| "allow #{ip}" } + ["deny all"]
            when 'deny'
              location.ips += control.ips.map { |ip| "deny #{ip}" } + ["allow all"]
            end
          end
        end

        if controls.any? { |c| c.basic_auths.present? }
          locations.each do |location|
            location.htpasswd_path = htpasswd_path
          end
        end
      end
    end
  end
end
