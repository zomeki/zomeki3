# encoding: utf-8
class GpCalendar::Piece::NearFutureEvent < Cms::Piece
  default_scope { where(model: 'GpCalendar::NearFutureEvent') }

  belongs_to :content, :foreign_key => :content_id, :class_name => 'GpCalendar::Content::Event'
end
