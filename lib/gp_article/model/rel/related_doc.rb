module GpArticle::Model::Rel::RelatedDoc
  extend ActiveSupport::Concern

  included do
    has_many :related_docs, class_name: 'GpArticle::RelatedDoc', dependent: :destroy, as: :relatable
    accepts_nested_attributes_for :related_docs, allow_destroy: true,
      reject_if: proc{|attrs| attrs['name'].blank?}
  end

end
