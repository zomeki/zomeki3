class Sys::Setting < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Base::Setting
  include Sys::Model::Auth::Manager

  set_config :common_ssl,
             name: '共有SSL',
             default_value: 'disabled',
             options: [['使用する', 'enabled'], ['使用しない', 'disabled']],
             form_type: :radio_buttons
  set_config :maintenance_mode,
             name: 'メンテナンスモード',
             default_value: 'disabled',
             options: [['有効にする', 'enabled'], ['無効にする', 'disabled']],
             form_type: :radio_buttons

  validates :name, presence: true

  class << self
    def use_common_ssl?
      return false if setting_value(:common_ssl) != 'enabled'
      return false if setting_extra_value(:common_ssl, :common_ssl_uri).blank?
      return true
    end

    def common_ssl_uri
      setting_extra_value(:common_ssl, :common_ssl_uri)
    end

    def is_maintenance_mode?
      return false if setting_value(:maintenance_mode) != 'enabled'
      #return false if setting_extra_value(:maintenance_mode).blank?
      return true
    end

    def get_maintenance_start_at
      start_at = setting_extra_value(:maintenance_mode, :maintenance_start_at)
      return nil if start_at.blank?
      "#{start_at}　から"
    end

    def get_maintenance_end_at
      end_at = setting_extra_value(:maintenance_mode, :maintenance_end_at)
      return nil if end_at.blank?
      "#{end_at}　まで"
    end

    private

    def setting(name)
      find_or_initialize_by(name: name)
    end

    def setting_value(name, default_value = nil)
      st = setting(name)
      return nil unless st
      return st.value.blank? ? default_value || st.default_value : st.value
    end

    def setting_extra_values(name)
      setting(name).try(:extra_values) || {}.with_indifferent_access
    end

    def setting_extra_value(name, extra_name)
      setting_extra_values(name)[extra_name]
    end
  end
end
