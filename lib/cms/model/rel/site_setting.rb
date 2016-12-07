module Cms::Model::Rel::SiteSetting
  attr_accessor :in_setting_site_admin_protocol
  attr_accessor :in_setting_site_basic_auth_state
  attr_accessor :in_setting_site_common_ssl
  attr_accessor :in_setting_site_pass_reminder_mail_sender
  attr_accessor :in_setting_site_file_upload_max_size
  attr_accessor :in_setting_site_extension_upload_max_size
  attr_accessor :in_setting_site_allowed_attachment_type

  SITE_SETTINGS = [:admin_protocol, :basic_auth_state, :common_ssl, :allowed_attachment_type,
    :pass_reminder_mail_sender, :file_upload_max_size, :extension_upload_max_size]
  #SITE_SETTINGS = [:admin_protocol]

  def self.included(mod)
  end

  def setting_site_admin_protocol
    setting = Cms::SiteSetting::AdminProtocol.where(site_id: id).first
    setting ? setting.value : nil;
  end

  def setting_site_basic_auth_state
    setting = Cms::SiteSetting::BasicAuth.where(site_id: id).first
    setting ? setting.value : nil;
  end

  def use_basic_auth?
    setting_site_basic_auth_state == 'enabled'
  end

  def use_common_ssl?
    Sys::Setting.use_common_ssl? && setting_site_common_ssl == 'enabled'
  end

  def setting_site_common_ssl
    setting = Cms::SiteSetting.where(:site_id => id, :name => 'common_ssl').first
    setting ? setting.value : nil;
  end

  def setting_site_common_ssl_label
    setting = Cms::SiteSetting.where(:site_id => id, :name => 'common_ssl').first
    state = setting ? setting.value : nil;
    Cms::SiteSetting::SSL_OPTIONS.each{|a| return a[0] if a[1] == state}
    return nil
  end

  def setting_site_pass_reminder_mail_sender
    setting = Cms::SiteSetting.where(:site_id => id, :name => 'pass_reminder_mail_sender').first
    setting ? setting.value : nil;
  end

  def setting_site_file_upload_max_size
    setting = Cms::SiteSetting.where(:site_id => id, :name => 'file_upload_max_size').first
    setting ? setting.value.presence || 5 : 5;
  end

  def setting_site_extension_upload_max_size
    setting = Cms::SiteSetting.where(:site_id => id, :name => 'extension_upload_max_size').first
    setting ? setting.value : nil;
  end

  def setting_site_allowed_attachment_type
    setting = Cms::SiteSetting.where(:site_id => id, :name => 'allowed_attachment_type').first
    setting ? setting.value : 'gif,jpg,png,pdf,doc,docx,xls,xlsx,ppt,pptx,odt,ods,odp';
  end

  def get_upload_max_size(ext)
    ext.gsub!(/^\./, '')
    list = ext_upload_max_size_list
    return list[ext.to_s] if list.include?(ext.to_s)
    return nil
  end

  def ext_upload_max_size_list
    return @ext_upload_max_size_list if @ext_upload_max_size_list
    csv = setting_site_extension_upload_max_size.to_s
    @ext_upload_max_size_list = {}

    csv.split(/(\r\n|\n)/u).each_with_index do |line, idx|
      line = line.to_s.gsub(/#.*/, "")
      line.strip!
      next if line.blank?

      data = line.split(/\s*,\s*/)
      ext = data[0].strip
      size = data[1].strip

      @ext_upload_max_size_list[ext.to_s] = size.to_i
    end if csv.present?
    return @ext_upload_max_size_list
  end

  def load_site_settings
    @in_setting_site_admin_protocol              = setting_site_admin_protocol
    @in_setting_site_basic_auth_state            = setting_site_basic_auth_state
    @in_setting_site_common_ssl                  = setting_site_common_ssl
    @in_setting_site_pass_reminder_mail_sender   = setting_site_pass_reminder_mail_sender
    @in_setting_site_file_upload_max_size        = setting_site_file_upload_max_size
    @in_setting_site_extension_upload_max_size   = setting_site_extension_upload_max_size
    @in_setting_site_allowed_attachment_type     = setting_site_allowed_attachment_type
  end

  def save_site_settings(options={})
    return true unless options
    return true unless options[:site_id]

    _site_id = options[:site_id]

    SITE_SETTINGS.each do |name|
      _value = eval("in_setting_site_#{name.to_s}")
      if setting = Cms::SiteSetting.where(:site_id => _site_id, :name => name.to_s).first
        setting.value = _value
        setting.save
      else
        Cms::SiteSetting.create(:site_id => _site_id, :name => name.to_s, :value => _value)
      end
    end
  end

end
