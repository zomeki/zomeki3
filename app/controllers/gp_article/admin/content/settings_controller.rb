class GpArticle::Admin::Content::SettingsController < Cms::Admin::Content::SettingsController
  def model
    GpArticle::Content::Setting
  end
end
