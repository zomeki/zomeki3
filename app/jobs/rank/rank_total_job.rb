class Rank::RankTotalJob < ApplicationJob
  after_perform do |job|
    Cms::Publisher::ContentCallbacks.new.enqueue(@content)
  end

  def perform(content)
    @content = content

    total_pages
    total_categories
  end

  def total_pages
    ActiveRecord::Base.transaction do
      Rank::Total.where(content_id: @content.id).delete_all

      t = Date.today
      ranking_terms.each do |termname, term|
        from, to = date_range(t, term)
        rank_table = Rank::Rank.arel_table
        results = Rank::Rank.select(:hostname, :page_path)
                            .select(rank_table[:pageviews].sum.as('pageviews'))
                            .select(rank_table[:visitors].sum.as('visitors'))
                            .where(content_id: @content.id)
                            .where(rank_table[:date].gteq(from.strftime('%F')).and(rank_table[:date].lteq(to.strftime('%F'))))
                            .group(:hostname, :page_path)
        totals = results.map do |result|
          latest_title = Rank::Rank.where(hostname: result.hostname, page_path: result.page_path)
                                   .order(date: :desc)
                                   .pluck(:page_title).first
          Rank::Total.new(content_id:  @content.id,
                              term:        term,
                              page_title:  latest_title,
                              hostname:    result.hostname,
                              page_path:   result.page_path,
                              pageviews:   result.pageviews,
                              visitors:    result.visitors)
        end
        Rank::Total.import(totals)
      end
    end
  end

  def total_categories
    cc_ids = GpCategory::Content::CategoryType.where(site_id: @content.site_id).pluck(:id)
    public_categories = GpCategory::CategoryType.public_state.where(content_id: cc_ids)
                                                .flat_map(&:public_root_categories)
                                                .flat_map(&:public_descendants)

    ActiveRecord::Base.transaction do
      Rank::Category.where(content_id: @content.id).delete_all
      public_categories.each do |category|
        cats = []
        docs = GpArticle::Doc.categorized_into(category.id).public_state
        docs.find_each do |doc|
          cats << Rank::Category.new(content_id:  @content.id,
                                     page_path:   doc.public_uri,
                                     category_id: category.id)
        end
        Rank::Category.import(cats)
      end
    end
  end

  private

  def ranking_terms
    [['すべて', 'all']] + Rank::Rank::TERMS
  end

  def date_range(t, term)
    case term
    when 'all'
      from = Date.new(2005, 1, 1)
      to   = t
    when 'previous_days'
      from = t.yesterday
      to   = t.yesterday
    when 'last_weeks'
      wday = t.wday == 0 ? 7 : t.wday
      from = t - (6 + wday).days
      to   = t - wday.days
    when 'last_months'
      from = (t - 1.month).beginning_of_month
      to   = (t - 1.month).end_of_month
    when 'this_weeks'
      from = t.yesterday - 7.days
      to   = t.yesterday
    end
    return [from, to]
  end
end
