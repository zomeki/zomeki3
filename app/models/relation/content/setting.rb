class Relation::Content::Setting < Cms::ContentSetting
  belongs_to :content, foreign_key: :content_id, class_name: 'Relation::Content::Doc'

end
