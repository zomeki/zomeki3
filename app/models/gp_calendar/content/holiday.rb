class GpCalendar::Content::Holiday < Cms::Content
  default_scope { where(model: 'GpCalendar::Holiday') }

  has_one :public_node, -> { public_state.order(:id) },
    foreign_key: :content_id, class_name: 'Cms::Node'

  has_many :holidays, foreign_key: :content_id, class_name: 'GpCalendar::Holiday', dependent: :destroy
end
