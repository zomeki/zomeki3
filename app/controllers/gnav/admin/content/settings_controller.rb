class Gnav::Admin::Content::SettingsController < Cms::Admin::Content::SettingsController
  def model
    Gnav::Content::Setting
  end
end
