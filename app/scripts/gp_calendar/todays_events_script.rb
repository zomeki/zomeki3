class GpCalendar::TodaysEventsScript < GpCalendar::BaseScript
  def publish
    publish_without_months
  end
end
