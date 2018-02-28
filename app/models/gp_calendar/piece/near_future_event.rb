class GpCalendar::Piece::NearFutureEvent < Cms::Piece
  default_scope { where(model: 'GpCalendar::NearFutureEvent') }

  belongs_to :content, class_name: 'GpCalendar::Content::Event'
end
