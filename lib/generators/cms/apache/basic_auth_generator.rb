module Cms
  module Apache
    class BasicAuthGenerator < Rails::Generators::Base
      source_root ::File.expand_path('../templates', __FILE__)

      class_option :site_id, desc: "Site ID"

      def create_configs
        load_sites.each do |site|
          @site = site

          if @site.basic_auth_state_enabled?
            template 'basic_auth/htaccess.erb', site.basic_auth_htaccess_path
          else
            remove_file site.basic_auth_htaccess_path
          end

          @basic_auth_users = @site.basic_auth_users.root_location.enabled
          template 'basic_auth/htpasswd.erb', site.basic_auth_htpasswd_path

          @basic_auth_users = @site.basic_auth_users.system_location.enabled
          template 'basic_auth/htpasswd.erb', "#{site.basic_auth_htpasswd_path}_system"

          locations = @site.basic_auth_users.directory_location.reorder(:target_location).group(:target_location).pluck(:target_location)
          locations.each do |location|
            @basic_auth_users = @site.basic_auth_users.directory_location.where(target_location: location).enabled
            template 'basic_auth/htpasswd.erb', "#{@site.basic_auth_htpasswd_path}_#{location}"
          end
        end
      end

      private

      def load_sites
        sites = Cms::Site.order(:id)
        sites.where!(id: options[:site_id]) if options[:site_id].present?
        sites
      end
    end
  end
end
