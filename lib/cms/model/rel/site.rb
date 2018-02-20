module Cms::Model::Rel::Site
  extend ActiveSupport::Concern

  included do
    belongs_to :site, class_name: 'Cms::Site'
    nested_scope :in_site, through: :site
  end
end
