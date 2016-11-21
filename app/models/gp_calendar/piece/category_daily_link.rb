class GpCalendar::Piece::CategoryDailyLink < Cms::Piece
  default_scope { where(model: 'GpCalendar::CategoryDailyLink') }

  belongs_to :content, :foreign_key => :content_id, :class_name => 'GpCalendar::Content::Event'

  def target_node
    return @target_node if defined? @target_node
    @target_node = content.public_nodes.find_by(id: setting_value(:target_node_id))
  end

  def category_ids
    setting_value(:category_ids).present? ? YAML.load(setting_value(:category_ids)) : []
  end

  def categories
    GpCategory::Category.where(id: category_ids)
  end

  def categories_label
    categories.pluck(:title).join(',')
  end


end
