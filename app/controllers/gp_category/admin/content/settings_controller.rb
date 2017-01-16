class GpCategory::Admin::Content::SettingsController < Cms::Admin::Content::SettingsController
  def model
    GpCategory::Content::Setting
  end
end
