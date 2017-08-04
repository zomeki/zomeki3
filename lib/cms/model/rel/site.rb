module Cms::Model::Rel::Site
  extend ActiveSupport::Concern

  included do
    belongs_to :site, class_name: 'Cms::Site'
    scope :in_site, ->(site) { where(site_id: site) }
  end
end
