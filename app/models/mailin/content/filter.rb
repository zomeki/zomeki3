class Mailin::Content::Filter < Cms::Content
  default_scope { where(model: 'Mailin::Filter') }

  has_many :filters, foreign_key: :content_id, class_name: 'Mailin::Filter', dependent: :destroy

  def enabled_filters
    filters.where(state: 'enabled')
  end

  def gp_article_contents
    GpArticle::Content::Doc.in_site(site_id)
  end

  def mail_host
    setting_extra_value(:mail, :host).to_s
  end

  def mail_port
    setting_extra_value(:mail, :port).to_s
  end

  def mail_username
    setting_extra_value(:mail, :username).to_s
  end

  def mail_password
    setting_extra_value(:mail, :password).to_s
  end

  def mail_protocol
    setting_extra_value(:mail, :protocol).to_s
  end

  def mail_protocol_apop?
    mail_protocol == 'apop'
  end

  def pop_cycle
    setting_extra_value(:mail, :pop_cycle).to_i
  end

  def default_user
    return unless user_id = setting_value(:default_user)
    Sys::User.find_by(id: user_id)
  end

  def execution_time?(time = Time.now)
    return false if pop_cycle == 0
    startup = time.min
    min_cycle = Mailin::Content::Setting.min_pop_cycle
    ((startup - min_cycle).to_f / pop_cycle).to_i != (startup.to_f / pop_cycle).to_i
  end
end
