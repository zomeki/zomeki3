class Tag::Admin::Content::SettingsController < Cms::Admin::Content::SettingsController
  def model
    Tag::Content::Setting
  end
end
