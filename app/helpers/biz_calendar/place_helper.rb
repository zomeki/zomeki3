module BizCalendar::PlaceHelper
  def business_hour_start_end_text(hour, time_style: '')
    return if hour.business_hours_start_time.blank? || hour.business_hours_end_time.blank?
    start_text = hour.business_hours_start_time.strftime(localize_ampm(time_style, hour.business_hours_start_time))
    end_text = hour.business_hours_end_time.strftime(localize_ampm(time_style, hour.business_hours_end_time))
    "#{start_text}～#{end_text}"
  end
end
