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

    @events = join_periods

    if criteria[:sort_key].present?
      @events = sort_by(criteria[:sort_key], criteria[:sort_order])
    end

    @events.order("min_started_on desc, min_ended_on desc")
  end

  private

  def join_periods
    events = GpCalendar::Event.arel_table
    periods = Cms::Period.arel_table
    subquery = @events.joins(:periods)
                      .select(Arel.sql('gp_calendar_events.*'),
                              periods[:started_on].minimum.as('min_started_on'),
                              periods[:ended_on].minimum.as('min_ended_on'))
                      .group(events[:id])
    GpCalendar::Event.from("(#{subquery.to_sql}) AS gp_calendar_events")
  end

  def sort_by(key, order)
    @events.order(key => (order.presence || :asc).to_sym)
  end
end
