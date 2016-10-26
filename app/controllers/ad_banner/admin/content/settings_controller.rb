class AdBanner::Admin::Content::SettingsController < Cms::Admin::Content::SettingsController
  def model
    AdBanner::Content::Setting
  end
end
