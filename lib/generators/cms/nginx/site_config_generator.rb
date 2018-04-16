module Cms
  module Nginx
    class SiteConfigGenerator < Rails::Generators::Base
      source_root ::File.expand_path('../templates', __FILE__)

      class_option :site_id, desc: "Site ID"

      def create_configs
        load_sites.each do |site|
          @site = site
          @locations = Cms::Nginx::LocationBuilder.new(@site).build
          template 'servers/server.conf.erb', @site.nginx_config_path

          if @site.admin_full_uri.present?
            template 'servers/admin_server.conf.erb', @site.nginx_admin_config_path
          else
            remove_file site.nginx_admin_config_path if ::File.exist?(site.nginx_admin_config_path)
          end
        end
      end

      def delete_configs
        deleted_site_ids = conf_site_ids - load_sites.pluck(:id)
        deleted_site_ids.each do |site_id|
          files = ["config/nginx/servers/site_#{'%04d' % site_id}.conf",
                   "config/nginx/admin_servers/site_#{'%04d' % site_id}.conf"]
          files.each do |file|
            remove_file file if ::File.exist?(file)
          end
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

    class Location
      include ActiveModel::Model

      attr_accessor :site
      attr_accessor :path, :try_files, :htpasswd_path
    end

    class LocationBuilder
      def initialize(site)
        @site = site
        @try_files = %w($uri $uri/index.html)
        @dynamic_dirs = load_dynamic_dirs
        @basic_auth_dirs = load_basic_auth_dirs
      end

      def build
        locations =  make_system_locations
        locations += make_public_locations
        locations += make_public_error_locations if @site.smart_phone_layout_same_as_pc?
        locations += make_default_public_locations

        append_request_uri_for_smartphone(locations) if @site.smart_phone_layout_same_as_pc?

        locations
      end

      private

      def load_dynamic_dirs
        @site.nodes.public_state.dynamic_models
             .map { |node| node.public_uri.chomp('/') }
      end

      def load_basic_auth_dirs
        return [] unless @site.use_basic_auth?
        @site.basic_auth_users.directory_location.enabled
                              .reorder(:target_location)
                              .group(:target_location)
                              .pluck(:target_location)
                              .map { |d| "/#{d}" }
                              .map { |d| d.chomp('/') }
      end

      def make_system_locations
        locations = [Location.new(path: "/#{ZomekiCMS::ADMIN_URL_PREFIX}", try_files: @try_files + ['@proxy']),
                     Location.new(path: "/_preview", try_files: @try_files + ['@proxy'])]

        if @site.use_basic_auth? && @site.basic_auth_users.system_location.enabled.exists?
          locations.each do |location|
            location.htpasswd_path = "#{@site.basic_auth_htpasswd_path}_system"
          end
        end

        locations
      end

      def make_public_locations
        dirs = (@basic_auth_dirs + @dynamic_dirs).uniq.sort_by { |d| d.count('/') }.reverse
        dirs.each_with_object([]) do |dir, locations|
          proxy = if dir.in?(@dynamic_dirs)
                    '@dynamic'
                  else
                    '@proxy'
                  end
          htpath = if @site.use_basic_auth?
                     if dir.in?(@basic_auth_dirs)
                       "#{@site.basic_auth_htpasswd_path}_#{dir.gsub(%r{^/}, '').gsub('/', '_')}"
                     elsif @site.basic_auth_users.all_location.enabled.exists?
                       @site.basic_auth_htpasswd_path
                     end
                   end

          locations << Location.new(path: "/_smartphone#{dir}", try_files: @try_files + [proxy], htpasswd_path: htpath)
          locations << Location.new(path: "/_mobile#{dir}", try_files: @try_files + ['@dynamic'], htpasswd_path: htpath)
          locations << Location.new(path: dir, try_files: @try_files + [proxy], htpasswd_path: htpath)
        end
      end

      def make_public_error_locations
        [Location.new(path: '/_smartphone/404.html', try_files: ['/404.html', '@proxy'])]
      end

      def make_default_public_locations
        locations = [Location.new(path: '/_smartphone', try_files: @try_files + ['@proxy']),
                     Location.new(path: '/_mobile', try_files: @try_files + ['@dynamic']),
                     Location.new(path: '/', try_files: @try_files + ['@proxy'])]

        if @site.use_basic_auth? && @site.basic_auth_users.all_location.enabled.exists?
          locations.each do |location|
            location.htpasswd_path = @site.basic_auth_htpasswd_path
          end
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
    end
  end
end
