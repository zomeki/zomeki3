class Cms::LinkCheckLog < ApplicationRecord
  include Sys::Model::Base

  belongs_to :link_check
  belongs_to :link_checkable, :polymorphic => true

  after_initialize :set_defaults

  private

  def set_defaults
    self.checked = false if self.has_attribute?(:checked) && self.checked.nil?
  end
end
