class Sys::Setting < Sys::Model::Base::Setting
  include Sys::Model::Base

  set_config :common_ssl, :name => "共有SSL", :default => 'disabled',
    options: [['使用する', 'enabled'], ['使用しない', 'disabled']],
    form_type: :radio_buttons
  set_config :pass_reminder_mail_sender, :name => "パスワード変更メール送信元アドレス", :default => 'noreply'
  set_config :file_upload_max_size, :name => "添付ファイル最大サイズ", :comment => 'MB', :default => 50
  set_config :maintenance_mode, :name => "メンテナンスモード", :default => 'disabled',
    options: [['有効にする', 'enabled'], ['無効にする', 'disabled']],
    form_type: :radio_buttons

  validates :name, presence: true

  def self.use_common_ssl?
    return false if Sys::Setting.value(:common_ssl) != 'enabled'
    return false if Sys::Setting.setting_extra_value(:common_ssl, :common_ssl_uri).blank?
    return true
  end

  def self.ext_upload_max_size_list
    return @ext_upload_max_size_list if @ext_upload_max_size_list
    csv = Sys::Setting.setting_extra_value(:file_upload_max_size, :extension_upload_max_size).to_s
    @ext_upload_max_size_list = {}

    csv.split(/(\r\n|\n)/u).each_with_index do |line, idx|
      line = line.to_s.gsub(/#.*/, "")
      line.strip!
      next if line.blank?

      data = line.split(/\s*,\s*/)
      ext = data[0].strip
      size = data[1].strip

      @ext_upload_max_size_list[ext.to_s] = size.to_i
    end
    return @ext_upload_max_size_list
  end

  def self.is_maintenance_mode?
    return false if Sys::Setting.value(:maintenance_mode) != 'enabled'
    #return false if Sys::Setting.setting_extra_value(:maintenance_mode).blank?
    return true
  end

  def self.get_maintenance_start_at
    return nil if Sys::Setting.setting_extra_value(:maintenance_mode, :maintenance_start_at).blank?
    "#{Sys::Setting.setting_extra_value(:maintenance_mode, :maintenance_start_at)}　から"
  end

  def self.get_maintenance_end_at
    return nil if Sys::Setting.setting_extra_value(:maintenance_mode, :maintenance_end_at).blank?
    "#{Sys::Setting.setting_extra_value(:maintenance_mode, :maintenance_end_at)}　まで"
  end

  def self.get_upload_max_size(ext)
    ext.gsub!(/^\./, '')
    list = Sys::Setting.ext_upload_max_size_list
    return list[ext.to_s] if list.include?(ext.to_s)
    return nil
  end

end
