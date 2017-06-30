module Cms::Model::Rel::Importation
  extend ActiveSupport::Concern

  included do
    has_many :importations, class_name: 'Cms::Importation', dependent: :destroy, as: :importable
  end
end
