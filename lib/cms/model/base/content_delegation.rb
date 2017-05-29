module Cms::Model::Base::ContentDelegation
  extend ActiveSupport::Concern

  included do
    delegate :site, to: :content
    delegate :site_id, to: :content
  end
end
