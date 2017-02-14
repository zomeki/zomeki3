module Cms::Model::Rel::SiteSetting
  extend ActiveSupport::Concern

  attr_accessor :in_setting_site_basic_auth_state
  attr_accessor :in_setting_site_common_ssl
  attr_accessor :in_setting_site_admin_mail_sender
  attr_accessor :in_setting_site_file_upload_max_size
  attr_accessor :in_setting_site_extension_upload_max_size
  attr_accessor :in_setting_site_allowed_attachment_type
  attr_accessor :in_setting_site_link_check
  attr_accessor :in_setting_site_kana_talk

  SITE_SETTINGS = [
    :basic_auth_state, :common_ssl, :allowed_attachment_type,
    :admin_mail_sender, :file_upload_max_size, :extension_upload_max_size, :link_check, :kana_talk
  ]

  included do
    after_save :save_site_settings
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

  def setting_site_admin_mail_sender
    setting = Cms::SiteSetting.where(:site_id => id, :name => 'admin_mail_sender').first
    setting ? setting.value : 'noreply'
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

  def setting_site_link_check
    setting = Cms::SiteSetting.where(:site_id => id, :name => 'link_check').first
    setting ? setting.value : 'enabled';
  end

  def setting_site_link_check_label
    Cms::SiteSetting::LINK_CHECK_OPTIONS.rassoc(setting_site_link_check).try(:first)
  end

  def setting_site_kana_talk
    setting = Cms::SiteSetting.where(:site_id => id, :name => 'kana_talk').first
    setting ? setting.value : 'enabled';
  end

  def setting_site_kana_talk_label
    Cms::SiteSetting::KANA_TALK_OPTIONS.rassoc(setting_site_kana_talk).try(:first)
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
    @in_setting_site_basic_auth_state            = setting_site_basic_auth_state
    @in_setting_site_common_ssl                  = setting_site_common_ssl
    @in_setting_site_admin_mail_sender           = setting_site_admin_mail_sender
    @in_setting_site_file_upload_max_size        = setting_site_file_upload_max_size
    @in_setting_site_extension_upload_max_size   = setting_site_extension_upload_max_size
    @in_setting_site_allowed_attachment_type     = setting_site_allowed_attachment_type
    @in_setting_site_link_check                  = setting_site_link_check
    @in_setting_site_kana_talk                   = setting_site_kana_talk
  end

  private

  def save_site_settings
    SITE_SETTINGS.each do |name|
      v = instance_variable_get("@in_setting_site_#{name}")
      next unless v
      setting = Cms::SiteSetting.where(site_id: id, name: name).first_or_initialize
      setting.value = v
      setting.save
    end
  end
end
