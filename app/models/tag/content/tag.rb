class Tag::Content::Tag < Cms::Content
  default_scope { where(model: 'Tag::Tag') }

  has_many :settings, foreign_key: :content_id, class_name: 'Tag::Content::Setting', dependent: :destroy
  has_many :tags, -> { order(last_tagged_at: :desc) },
                  foreign_key: :content_id, class_name: 'Tag::Tag', dependent: :destroy

  # node
  has_one :public_node, -> { public_state.where(model: 'Tag::Tag').order(:id) },
                        foreign_key: :content_id, class_name: 'Cms::Node'

  def public_path
    site.public_path
  end

  def list_style
    setting_value(:list_style).to_s
  end

  def date_style
    setting_value(:date_style).to_s
  end
end
