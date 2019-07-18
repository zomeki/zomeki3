class AdBanner::BannersFinder < ApplicationFinder
  def initialize(banners)
    @banners = banners
  end

  def search(criteria)
    @banners = with_target_state(criteria[:target_state]) if criteria[:target_state].present?
    @banners
  end

  private

  def arel_table
    @banners.arel_table
  end

  def with_target_state(target_state)
    case target_state
    when 'processing'
      @banners.where(state: %w(draft approvable approved prepared))
    when 'public'
      @banners.where(state: 'public')
    when 'closed'
      @banners.where(state: 'closed')
    when 'all'
      @banners.all
    else
      @banners.none
    end
  end
end
