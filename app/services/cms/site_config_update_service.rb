class Cms::SiteConfigUpdateService < ApplicationService
  def initialize(site)
    @site = site
  end

  def update
    Rails::Generators.invoke('cms:apache:basic_auth', ['--force', "--site_id=#{@site.id}"])
    Rails::Generators.invoke('cms:nginx:site_config', ['--force', "--site_id=#{@site.id}"])
    Cms::Site.reload_servers
  end
end
