class Cms::LinkCheckLog < ApplicationRecord
  include Sys::Model::Base

  belongs_to :link_check
  belongs_to :link_checkable, :polymorphic => true

  after_initialize :set_defaults

  def is_current_site_log?(site = Core.site)
    return false unless link_checkable
    if link_checkable.is_a?(GpArticle::Doc)
      return link_checkable.content && link_checkable.content.site_id == site.id
    elsif link_checkable.is_a?(Cms::Node)
      return link_checkable.site_id == site.id
    else
      return false
    end
  end

  private

  def set_defaults
    self.checked = false if self.has_attribute?(:checked) && self.checked.nil?
  end

end
