class Cms::SiteConfigService < ApplicationService
  def initialize(site)
    @site = site
  end

  def update
    Rails::Generators.invoke('cms:apache:basic_auth', ['--force', "--site_id=#{@site.id}"])
    Rails::Generators.invoke('cms:nginx:site_config', ['--force', "--site_id=#{@site.id}"])

    FileUtils.touch Rails.root.join('tmp/reload_servers.txt')
  end
end
