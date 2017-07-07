module Cms::Model::Rel::Content
  extend ActiveSupport::Concern

  included do
    belongs_to :content, class_name: 'Cms::Content'
    delegate :site, to: :content
    delegate :site_id, to: :content
    scope :in_site, ->(site) { where(content_id: Cms::Content.where(site_id: site)) }
  end

  def inherited_concept
    (respond_to?(:concept) && concept) || content.inherited_concept
  end
end
