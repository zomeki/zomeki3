module Cms::Model::Rel::SiteSetting
  extend ActiveSupport::Concern

  IN_SETTING_NAMES = Cms::SiteSetting.configs.keys.map { |name| :"in_setting_site_#{name}" }
  IN_SETTING_NAMES.each do |in_name|
    attr_accessor in_name
  end

  included do
    after_save :save_site_settings
  end

  def use_access_control?
    setting_value(:access_control_state) == 'enabled'
  end

  def use_common_ssl?
    Sys::Setting.use_common_ssl? && setting_value(:common_ssl) == 'enabled'
  end

  def admin_mail_sender
    setting_value(:admin_mail_sender)
  end

  def file_upload_max_size
    (setting_value(:file_upload_max_size).presence || 5).to_i
  end

  def ext_upload_max_size
    return @ext_upload_max_size if @ext_upload_max_size

    @ext_upload_max_size = {}
    csv = setting_value(:extension_upload_max_size).to_s
    csv.split(/\r\n|\r|\n/).each do |line|
      ext, size = line.gsub(/#.*/, "").split(',').map(&:strip)
      @ext_upload_max_size[ext] = size.to_i if ext.present? && size.present?
    end
    @ext_upload_max_size
  end

  def file_upload_max_size_for(ext)
    ext_upload_max_size[ext] || file_upload_max_size
  end

  def allowed_attachment_type
    setting_value(:allowed_attachment_type)
  end

  def allowed_attachment_types
    allowed_attachment_type.to_s.split(',').map { |type| type.strip.downcase }.select(&:present?)
  end

  def link_check_enabled?
    setting_value(:link_check) == 'enabled'
  end

  def link_check_hour?(hour)
    setting_value(:link_check) == 'enabled' && setting_value(:link_check_hour) == hour.to_s
  end

  def link_check_domain_type
    setting_value(:link_check_domain_type)
  end

  def link_check_exclusion_regexp
    regexps = setting_value(:link_check_exclusion).to_s.split(/[\r\n]+/).map { |ex| /^#{Regexp.escape(ex)}/ }
    regexps.present? ? Regexp.union(regexps) : nil
  end

  def adobe_reader_link_enabled?
    setting_value(:adobe_reader_link) == 'enabled'
  end

  def use_kana?
    setting_value(:kana_talk).in?(%w(enabled kana_only))
  end

  def use_talk?
    setting_value(:kana_talk) == 'enabled'
  end

  def map_coordinate
    setting_value(:map_coordinate)
  end

  def zip_download_max_size
    setting_value(:zip_download_max_size).to_i * (1024**2)
  end

  def use_datetime_preview?
    setting_value(:datetime_preview) == 'enabled'
  end

  def map_source
    setting_value(:map_source)
  end

  def use_navigation?
    setting_value(:map_source) == 'google'
  end

  def load_site_settings
    Cms::SiteSetting.configs.keys.each do |name|
      instance_variable_set("@in_setting_site_#{name}", setting_value(name))
    end
  end

  private

  def setting_value(name)
    setting = settings.detect { |st| st.name == name.to_s } || settings.build(name: name)
    setting.value
  end

  def save_site_settings
    Cms::SiteSetting.configs.keys.each do |name|
      v = instance_variable_get("@in_setting_site_#{name}")
      next unless v
      setting = Cms::SiteSetting.where(site_id: id, name: name).first_or_initialize
      setting.value = v
      setting.save
    end
  end
end
