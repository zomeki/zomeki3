class Map::Admin::Content::SettingsController < Cms::Admin::Content::SettingsController
  def model
    Map::Content::Setting
  end
end
