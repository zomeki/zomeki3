class GpCalendar::Admin::Content::SettingsController < Cms::Admin::Content::SettingsController
  def model
    GpCalendar::Content::Setting
  end
end
