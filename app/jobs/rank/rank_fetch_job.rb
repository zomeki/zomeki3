class Rank::RankFetchJob < ApplicationJob
  def perform(content, start_date = nil)
    @content = content
    return false if @content.setting_value(:web_property_id).blank?
    return false if @content.access_token.blank?

    profile = fetch_profile
    return false unless profile

    items = fetch_google_analytics(profile, start_date)
    items.each_with_index do |item, i|
      rank = Rank::Rank.where(content_id: @content.id)
                       .where(page_title: item.page_title)
                       .where(hostname:   item.hostname)
                       .where(page_path:  item.page_path)
                       .where(date:       item.date)
                       .first_or_create
      rank.pageviews = item.pageviews
      rank.visitors  = item.unique_pageviews
      rank.save!
    end
  end

  private

  def fetch_profile
    Garb::Session.access_token = @content.access_token
    Garb::Management::Profile.all.detect { |p| p.web_property_id == @content.setting_value(:web_property_id) }
  end

  def fetch_google_analytics(profile, start_date = nil)
    limit = 1000
    items = google_analytics(profile, limit, nil, start_date)
    repeat_times = items.total_results / limit

    copy = items.to_a
    if (repeat_times != 0)
      repeat_times.times do |x|
        copy += google_analytics(profile, limit, (x+1)*limit + 1, start_date).to_a
      end
    end
    copy
  end

  def google_analytics(profile, limit, offset, start_date)
    start_date = Date.new(start_date.year, start_date.month, start_date.day) unless start_date.nil?
    start_date = Date.new(2005,01,01) if start_date.blank? || start_date < Date.new(2005,01,01)

    Rank::GoogleAnalytics.results(profile, limit: limit, offset: offset, start_date: start_date)
  end
end
