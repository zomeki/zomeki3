class Relation::Content::Doc < Cms::Content
  default_scope { where(model: 'Relation::Doc') }

  has_many :settings, -> { order(:sort_no) },
    foreign_key: :content_id, class_name: 'Relation::Content::Setting', dependent: :destroy

  has_many :docs, foreign_key: :content_id, class_name: 'Relation::Doc', dependent: :destroy

end
