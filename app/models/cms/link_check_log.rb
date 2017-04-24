class Cms::LinkCheckLog < ApplicationRecord
  include Sys::Model::Base

  RESULT_STATE_OPTIONS = [['○','success'],['×','failure'],['－','skip']]

  belongs_to :site
  belongs_to :link_checkable, polymorphic: true

  after_initialize :set_defaults

  scope :search_with_params, ->(criteria) {
    rel = all
    rel.where!(result_state: criteria[:result_state]) if criteria && criteria[:result_state].present?
    rel
  }

  def result_state_mark
    RESULT_STATE_OPTIONS.rassoc(result_state).try(:first)
  end

  private

  def set_defaults
    self.checked = false if self.has_attribute?(:checked) && self.checked.nil?
  end
end
