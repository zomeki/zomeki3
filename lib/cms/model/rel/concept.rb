module Cms::Model::Rel::Concept
  extend ActiveSupport::Concern

  included do
    belongs_to :concept, foreign_key: :concept_id, class_name: 'Cms::Concept'
  end
end
