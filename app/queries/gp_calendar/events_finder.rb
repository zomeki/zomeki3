class GpCalendar::EventsFinder < ApplicationFinder
  def initialize(events)
    @events = events
  end

  def search(criteria)
    criteria ||= {}

    [:state].each do |key|
      @events = @events.where(key => criteria[key]) if criteria[key].present?
    end

    @events = @events.search_with_text(:title, criteria[:title]) if criteria[:title].present?

    if criteria[:date].present?
      date = Date.parse(criteria[:date]) rescue nil
      @events = @events.scheduled_on(date) if date
    end

    case criteria[:order]
    when 'created_at_desc'
      @events = @events.order(created_at: :desc)
    when 'created_at_asc'
      @events = @events.order(created_at: :asc)
    end

    @events
  end
end
