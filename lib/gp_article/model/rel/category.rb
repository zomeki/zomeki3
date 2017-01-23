module GpArticle::Model::Rel::Category
  extend ActiveSupport::Concern

  included do
    after_save :save_categories, if: -> { defined? @in_category_ids }
    after_save :save_event_categories, if: -> { defined? @in_event_category_ids }
    after_save :save_marker_categories, if: -> { defined? @in_marker_category_ids }
  end

  def in_category_ids=(val)
    @in_category_ids = val
  end

  def in_category_ids
    @in_category_ids ||= make_category_params(categories)
  end

  def in_event_category_ids=(val)
    @in_event_category_ids = val
  end

  def in_event_category_ids
    @in_event_category_ids ||= make_category_params(event_categories)
  end

  def in_marker_category_ids=(val)
    @in_marker_category_ids = val
  end

  def in_marker_category_ids
    @in_marker_category_ids ||= make_category_params(marker_categories)
  end

  private

  def make_category_params(categories)
    params = categories.group_by { |c| c.category_type_id.to_s }
    params.each { |ctid, cats| params[ctid] = cats.to_a.map {|c| c.id.to_s } }
    params
  end

  def save_categories
    self.category_ids = in_category_ids.values.flatten.select(&:present?).map(&:to_i).uniq
  end

  def save_event_categories
    self.event_category_ids = in_event_category_ids.values.flatten.select(&:present?).map(&:to_i).uniq
  end

  def save_marker_categories
    self.marker_category_ids = in_marker_category_ids.values.flatten.select(&:present?).map(&:to_i).uniq
  end
end
