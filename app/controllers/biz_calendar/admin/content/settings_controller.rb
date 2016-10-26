class BizCalendar::Admin::Content::SettingsController < Cms::Admin::Content::SettingsController
  def model
    BizCalendar::Content::Setting
  end
end
