class Survey::Admin::Content::SettingsController < Cms::Admin::Content::SettingsController
  def model
    Survey::Content::Setting
  end
end
