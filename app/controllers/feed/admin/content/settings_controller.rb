class Feed::Admin::Content::SettingsController < Cms::Admin::Content::SettingsController
  def model
    Feed::Content::Setting
  end
end
