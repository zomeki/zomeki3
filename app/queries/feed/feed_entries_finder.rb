class Feed::FeedEntriesFinder < ApplicationFinder
  def initialize(entries)
    @entries = entries
  end

  def search(criteria)
    criteria.each do |n, v|
      next if v.to_s == ''
      case n
      when 's_id'
        @entries = @entries.where(id: v)
      when 's_title'
        @entries = @entries.search_with_text(:title, v)
      end
    end

    @entries
  end
end
