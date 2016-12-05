class Relation::Admin::Content::SettingsController < Cms::Admin::Content::SettingsController
  def model
    Relation::Content::Setting
  end
end
