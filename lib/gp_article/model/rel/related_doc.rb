module GpArticle::Model::Rel::RelatedDoc
  extend ActiveSupport::Concern

  included do
    has_many :related_docs, class_name: 'GpArticle::RelatedDoc', dependent: :destroy, as: :relatable
    accepts_nested_attributes_for :related_docs, allow_destroy: true,
      reject_if: proc{|attrs| attrs['name'].blank?}
  end

  def relate_docs
    related_docs.map(&:target_doc).compact
  end

  def public_relate_docs
    @public_relate_docs ||= relate_docs.select(&:state_public?)
  end

  def relatee_docs
   GpArticle::Doc.where(id: GpArticle::RelatedDoc.where(content_id: content_id, name: name).select(:relatable_id))
  end

  def public_relatee_docs
    relatee_docs.where(state: 'public')
  end
end
