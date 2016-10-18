class Feed::Content::Feed < Cms::Content
  default_scope { where(model: 'Feed::Feed') }

  has_one :public_node, -> { public_state.where(model: 'Feed::FeedEntry').order(:id) },
    foreign_key: :content_id, class_name: 'Cms::Node'

  has_many :settings, -> { order(:sort_no) },
    foreign_key: :content_id, class_name: 'Feed::Content::Setting', dependent: :destroy

  has_many :feeds, foreign_key: :content_id, class_name: 'Feed::Feed', dependent: :destroy
  has_many :entries, foreign_key: :content_id, class_name: 'Feed::FeedEntry', dependent: :destroy

  def public_entries
    entries.where(state: 'public').reorder(entry_updated: :desc, id: :desc)
  end

  def list_style
    setting_value(:list_style).to_s
  end
  
  def date_style
    '%Y年%m月%d日 %H時%M分'
  end
  
  def time_style
    '%H時%M分'
  end

  def wrapper_tag
    setting_extra_value(:list_style, :wrapper_tag) || WRAPPER_TAG_OPTIONS.first.last
  end
end
