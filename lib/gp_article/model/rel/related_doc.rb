module GpArticle::Model::Rel::RelatedDoc
  extend ActiveSupport::Concern

  included do
    has_many :related_docs, class_name: 'GpArticle::RelatedDoc', dependent: :destroy, as: :relatable
    accepts_nested_attributes_for :related_docs, allow_destroy: true,
      reject_if: proc{|attrs| attrs['name'].blank?}
  end

  def all_related_docs
    related_docs.map(&:target_doc).compact
  end

  def public_related_docs
    @public_related_docs ||= all_related_docs.select(&:state_public?)
  end
end
