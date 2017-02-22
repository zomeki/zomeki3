class Cms::LinkCheckLog < ApplicationRecord
  include Sys::Model::Base

  belongs_to :site
  belongs_to :link_checkable, polymorphic: true

  after_initialize :set_defaults

  scope :search_with_params, ->(criteria) {
    rel = all
    rel.where!(result: criteria[:only] == 'succeeded') if criteria && criteria[:only].present?
    rel
  }

  private

  def set_defaults
    self.checked = false if self.has_attribute?(:checked) && self.checked.nil?
  end
end
