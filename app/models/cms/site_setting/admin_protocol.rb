class Cms::SiteSetting::AdminProtocol < Cms::SiteSetting

  ADMIN_PROTOCOLS = [['http', 'http'], ['https', 'https']]

  validates :value, uniqueness: { scope: :name }

  default_scope { where(name: 'admin_protocol') }

  def self.core_domain?
    mode = Zomeki.config.application['sys.core_domain'] || 'site'
    return mode == 'core'
  end

  def self.core_domain(site, options={})
    default_uri = site.admin_full_uri.presence || site.full_uri
    d = core_domain? ? Core.full_uri : default_uri;
    return d if options[:freeze_protocol] && options[:freeze_protocol] == true

    _admin_protocol = site.setting_site_admin_protocol
    if _admin_protocol == 'https'
      d.gsub(/^http[^s]/, "https:")
    else
      d.gsub(/^https/, "http")
    end
  end

end
