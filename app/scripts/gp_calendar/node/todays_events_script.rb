class GpCalendar::Node::TodaysEventsScript < GpCalendar::Node::BaseScript
  def publish
    publish_without_months
  end
end
