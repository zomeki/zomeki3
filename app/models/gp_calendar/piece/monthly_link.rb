# encoding: utf-8
class GpCalendar::Piece::MonthlyLink < Cms::Piece
  default_scope { where(model: 'GpCalendar::MonthlyLink') }

  belongs_to :content, :foreign_key => :content_id, :class_name => 'GpCalendar::Content::Event'

  def target_node
    return @target_node if defined? @target_node
    @target_node = content.public_nodes.find_by(id: setting_value(:target_node_id))
  end
end
