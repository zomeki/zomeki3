module GpCategory::Model::Rel::Category
  extend ActiveSupport::Concern

  included do
    has_many :categorizations, class_name: 'GpCategory::Categorization', as: :categorizable, dependent: :destroy
    has_many :categories, class_name: 'GpCategory::Category', through: :categorizations
    after_save :save_categories, if: -> { defined? @in_category_ids }

    scope :categorized_into, ->(categories, categorized_as: nil, alls: false) {
      cats = GpCategory::Categorization.select(:categorizable_id)
                                       .where(categorizable_type: self.to_s, categorized_as: categorized_as)
      if alls
        Array(categories).inject(all) { |rel, c| rel.where(id: cats.where(category_id: c)) }
      else
        where(id: cats.where(category_id: categories))
      end
    }
  end

  def in_category_ids=(val)
    @in_category_ids = val
  end

  def in_category_ids
    @in_category_ids ||= make_category_params(categories)
  end

  private

  def make_category_params(categories)
    params = categories.group_by { |c| c.category_type_id.to_s }
    params.each { |ctid, cats| params[ctid] = cats.to_a.map {|c| c.id.to_s } }
    params
  end

  def save_categories
    category_ids = in_category_ids.values.flatten.select(&:present?).map(&:to_i).uniq
    self.category_ids = category_ids
  end
end
