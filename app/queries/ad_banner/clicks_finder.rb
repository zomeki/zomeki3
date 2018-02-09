class AdBanner::ClicksFinder < ApplicationFinder
  def initialize(clicks = AdBanner::Click.all)
    @clicks = clicks
  end

  def search(criteria)
    criteria ||= {}

    @clicks = @clicks.search_with_text(:remote_addr, :user_agent, criteria[:keyword]) if criteria[:keyword].present?

    if criteria[:start_date].present?
      start_date = Date.parse(criteria[:start_date]).beginning_of_day rescue nil
    end
    if criteria[:end_date].present?
      end_date = Date.parse(criteria[:end_date]).end_of_day rescue nil
    end

    if start_date || end_date
      @clicks = @clicks.dates_intersects(:created_at, :created_at, start_date, end_date)
    end

    @clicks
  end
end
