module Cms::Model::Rel::SiteSetting
  extend ActiveSupport::Concern

  IN_SETTING_NAMES = Cms::SiteSetting.configs.keys.map { |name| :"in_setting_site_#{name}" }
  IN_SETTING_NAMES.each do |in_name|
    attr_accessor in_name
  end

  included do
    after_save :save_site_settings
  end

  def use_basic_auth?
    setting_value(:basic_auth_state) == 'enabled'
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

  def allowed_attachment_type
    setting_value(:allowed_attachment_type)
  end

  def link_check_enabled?
    setting_value(:link_check) == 'enabled'
  end

  def link_check_hour?(hour)
    setting_value(:link_check) == 'enabled' && setting_value(:link_check_hour) == hour.to_s
  end

  def link_check_exclusion_regexp
    regexps = setting_value(:link_check_exclusion).to_s.split(/[\r\n]+/).map { |ex| /^#{Regexp.escape(ex)}/ }
    regexps.present? ? Regexp.union(regexps) : nil
  end

  def accessibility_check_enabled?
    setting_value(:accessibility_check) == 'enabled'
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

  def get_upload_max_size(ext)
    ext.gsub!(/^\./, '')
    list = ext_upload_max_size_list
    return list[ext.to_s] if list.include?(ext.to_s)
    return nil
  end

  def ext_upload_max_size_list
    return @ext_upload_max_size_list if @ext_upload_max_size_list

    csv = setting_value(:extension_upload_max_size).to_s
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
