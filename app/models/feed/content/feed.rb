# encoding: utf-8
class Feed::Content::Feed < Cms::Content
  
  default_scope { where(model: 'Feed::Feed') }

  has_many :feeds, :foreign_key => :content_id, :class_name => 'Feed::Feed', :dependent => :destroy
  has_many :entries, :foreign_key => :content_id, :class_name => 'Feed::FeedEntry', :dependent => :destroy

  before_create :set_default_settings

  def public_node
    Cms::Node.where(state: 'public', content_id: id, model: 'Feed::FeedEntry').order(:id).first
  end
  
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

#TODO: DEPRECATED
  def feed_node
    return @feed_node if @feed_node
    @feed_node = Cms::Node.where(state: 'public', content_id: id, model: 'Feed::Feed').order(:id).first
  end


  def set_default_settings
    in_settings[:list_style] = '@title_link@(@publish_date@)' unless setting_value(:list_style)
  end
end
