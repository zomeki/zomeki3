class Reception::Admin::Content::SettingsController < Cms::Admin::Content::SettingsController
  def model
    Reception::Content::Setting
  end
end
