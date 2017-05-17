class Rank::TotalsFinder < FinderQuery
  def initialize(relation)
    @relation = relation
  end

  def search(content, term, target, category_options = {})
    hostname   = URI.parse(content.site.full_uri).host
    exclusion  = content.setting_value(:exclusion_url).strip.split(/[ |\t|\r|\n|\f]+/) rescue exclusion = ''
    rank_table = Rank::Total.arel_table

    ranks = @relation.select('*')
                     .select(rank_table[target].as('accesses'))
                     .where(content_id: content.id)
                     .where(term:       term)
                     .where(hostname:   hostname)
                     .where(rank_table[:page_path].not_in(exclusion))

    category_ids = load_category_ids(content, category_options)

    if category_ids.size > 0
      rank_cate_table = Rank::Category.arel_table
      ranks = ranks.where(Rank::Category.select(:page_path)
                                        .where(rank_cate_table[:content_id].eq(content.id))
                                        .where(rank_cate_table[:page_path].eq(rank_table[:page_path]))
                                        .where(category_id: category_ids).exists)
    end

    ranks = ranks.order('accesses DESC')
    ranks
  end

  private

  def load_category_ids(content, category_option: nil, gp_category: nil, category_type: nil, category: nil, current_item: nil)
    category_ids = []

    if category_option == 'on'
      case current_item
      when GpCategory::CategoryType
        category_ids += current_item.categories.map(&:id)
      when GpCategory::Category
        category_ids += current_item.descendants.map(&:id)
      end
    end

    if category.to_i > 0
      category_ids += GpCategory::Category.find_by(id: category.to_i).descendants.map(&:id)
    elsif category_type.to_i > 0
      category_ids += GpCategory::CategoryType.find_by(id: category_type.to_i).categories.pluck(:id)
    elsif gp_category.to_i > 0
      category_content_ids = GpCategory::Content::CategoryType.where(site_id: content.site_id).pluck(:id)
      category_ids += GpCategory::CategoryType.where(content_id: category_content_ids)
                                              .flat_map { |ct| ct.categories.pluck(:id) }
    end

    category_ids.flatten.uniq
  end
end
