class Cms::Lib::Nginx::Location
  include ActiveModel::Model

  attr_accessor :site
  attr_accessor :path, :name, :try_files, :htpasswd_path

  class << self
    def make(site)
      locations =  make_system_locations(site)
      locations += make_public_locations(site)
      locations += make_default_public_locations(site)

      append_request_uri_for_smartphone(locations) if site.smart_phone_layout_same_as_pc?
      locations
    end

    private

    def make_system_locations(site)
      locations = [
        new(site: site, path: "/#{ZomekiCMS::ADMIN_URL_PREFIX}", name: "/#{ZomekiCMS::ADMIN_URL_PREFIX}", try_files: ['@proxy']),
        new(site: site, path: "/_preview", name: "/_preview", try_files: ['@proxy'])
      ]

      if site.use_basic_auth? && site.basic_auth_users.system_location.enabled.exists?
        locations.each do |location|
          location.htpasswd_path = "#{site.basic_auth_htpasswd_path}_system"
        end
      end

      locations
    end

    def load_dynamic_dirs(site)
      site.nodes.public_state.dynamic_models
          .map { |node| node.public_uri.chomp('/') }
    end

    def load_basic_auth_dirs(site)
      site.basic_auth_users.directory_location.enabled
                            .reorder(:target_location)
                            .group(:target_location)
                            .pluck(:target_location)
                            .map { |d| "/#{d}" }
                            .map { |d| d.chomp('/') }
    end

    def make_public_locations(site)
      dynamic_dirs = load_dynamic_dirs(site)
      basic_auth_dirs = if site.use_basic_auth?
                          load_basic_auth_dirs(site)
                        else
                          []
                        end

      dirs = (basic_auth_dirs + dynamic_dirs).uniq.sort_by { |d| d.count('/') }.reverse
      dirs.each_with_object([]) do |dir, array|
        proxy = if dir.in?(dynamic_dirs) 
                  '@dynamic'
                else
                  '@proxy'
                end
        htpasswd_path = if site.use_basic_auth? && dir.in?(basic_auth_dirs)
                          "#{site.basic_auth_htpasswd_path}_#{dir.gsub(%r{^/}, '').gsub('/', '_')}"
                        elsif site.use_basic_auth? && site.basic_auth_users.all_location.enabled.exists?
                          site.basic_auth_htpasswd_path
                        end
        array << new(site: site, name: dir, path: "/_smartphone#{dir}", try_files: [proxy], htpasswd_path: htpasswd_path)
        array << new(site: site, name: dir, path: "/_mobile#{dir}", try_files: ['@dynamic'], htpasswd_path: htpasswd_path)
        array << new(site: site, name: dir, path: "#{dir}", try_files: [proxy], htpasswd_path: htpasswd_path)
      end
    end

    def make_default_public_locations(site)
      locations = [
        new(site: site, name: '/', path: '/_smartphone', try_files: ['@proxy']),
        new(site: site, name: '/', path: '/_mobile', try_files: ['@dynamic']),
        new(site: site, name: '/', path: '/', try_files: ['@proxy'])
      ]

      if site.use_basic_auth? && site.basic_auth_users.all_location.enabled.exists?
        locations.each do |location|
          location.htpasswd_path = site.basic_auth_htpasswd_path
        end
      end

      locations
    end

    def append_request_uri_for_smartphone(locations)
      locations.each do |location|
        if location.path =~ %r{/_smartphone} && location.try_files.include?('@proxy')
          location.try_files = %w($request_uri $request_uri/index.html) + location.try_files
        end
      end
      locations
    end
  end
end
