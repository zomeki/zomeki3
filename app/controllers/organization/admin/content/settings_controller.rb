class Organization::Admin::Content::SettingsController < Cms::Admin::Content::SettingsController
  def model
    Organization::Content::Setting
  end
end
