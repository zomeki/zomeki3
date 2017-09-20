class Mailin::Admin::Content::SettingsController < Cms::Admin::Content::SettingsController
  def model
    Mailin::Content::Setting
  end
end
