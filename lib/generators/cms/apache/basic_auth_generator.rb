module Cms
  module Apache
    class BasicAuthGenerator < Rails::Generators::Base
      source_root ::File.expand_path('../templates', __FILE__)

      class_option :site_id, desc: "Site ID"

      def create_configs
        load_sites.each do |site|
          @site = site

          if @site.use_access_control?
            template 'basic_auth/htaccess.erb', site.basic_auth_htaccess_path
          else
            remove_file site.basic_auth_htaccess_path
          end

          @controls = @site.access_controls.where(state: 'enabled', target_type: '_system').order(:id)
          template 'basic_auth/htpasswd.erb', "#{site.basic_auth_htpasswd_path}_system" if @controls.present?

          @controls = @site.access_controls.where(state: 'enabled', target_type: 'all').order(:id)
          template 'basic_auth/htpasswd.erb', site.basic_auth_htpasswd_path if @controls.present?

          dir_controls = @site.access_controls.where(state: 'enabled', target_type: 'directory').order(:id)
          locations = dir_controls.reorder(:target_location)
                                  .group(:target_location)
                                  .pluck(:target_location)
          locations.each do |location|
            @controls = dir_controls.where(target_location: location)
            template 'basic_auth/htpasswd.erb', "#{@site.basic_auth_htpasswd_path}_#{location.gsub('/', '_')}" if @controls.present?
          end
        end
      end

      private

      def load_sites
        sites = Cms::Site.where(state: 'public').order(:id)
        sites.where!(id: options[:site_id]) if options[:site_id].present?
        sites
      end
    end
  end
end
