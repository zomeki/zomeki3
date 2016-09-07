module Cms::Model::Rel::SiteSetting
  attr_accessor :in_setting_site_admin_protocol
  attr_accessor :in_setting_site_common_ssl
  attr_accessor :in_setting_site_pass_reminder_mail_sender
  attr_accessor :in_setting_site_file_upload_max_size
  attr_accessor :in_setting_site_extension_upload_max_size

  #SITE_SETTINGS = [:admin_protocol, :common_ssl,
  #  :pass_reminder_mail_sender, :file_upload_max_size, :extension_upload_max_size]
  SITE_SETTINGS = [:admin_protocol]

  def self.included(mod)
  end

  def setting_site_admin_protocol
    setting = Cms::SiteSetting::AdminProtocol.where(site_id: id).first
    setting ? setting.value : nil;
  end

  def setting_site_common_ssl
    setting = Cms::SiteSetting.where(:site_id => id, :name => 'common_ssl').first
    setting ? setting.value : nil;
  end

  def setting_site_common_ssl_label
    setting = Cms::SiteSetting.where(:site_id => id, :name => 'common_ssl').first
    state = setting ? setting.value : nil;
    Cms::SiteSetting::SSL_OPTIONS.each{|a| return a if a[1] == state}
    return nil
  end

  def setting_site_pass_reminder_mail_sender
    setting = Cms::SiteSetting.where(:site_id => id, :name => 'pass_reminder_mail_sender').first
    setting ? setting.value : nil;
  end

  def setting_site_file_upload_max_size
    setting = Cms::SiteSetting.where(:site_id => id, :name => 'file_upload_max_size').first
    setting ? setting.value : 5;
  end

  def setting_site_extension_upload_max_size
    setting = Cms::SiteSetting.where(:site_id => id, :name => 'extension_upload_max_size').first
    setting ? setting.value : nil;
  end

  def ext_upload_max_size_list
    return @ext_upload_max_size_list if @ext_upload_max_size_list
    csv = setting_extension_upload_max_size.to_s
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
    @in_setting_site_setting_common_ssl          = setting_site_common_ssl
    @in_setting_site_pass_reminder_mail_sender   = setting_site_pass_reminder_mail_sender
    @in_setting_site_file_upload_max_size        = setting_site_file_upload_max_size
    @in_setting_site_extension_upload_max_size   = setting_site_extension_upload_max_size
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
