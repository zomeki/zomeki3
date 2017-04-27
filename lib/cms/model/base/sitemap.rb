module Cms::Model::Base::Sitemap
  extend ActiveSupport::Concern

  SITEMAP_STATE_OPTIONS = [['表示', 'visible'], ['非表示', 'hidden']]

  included do
    scope :visible_in_sitemap, -> { where(sitemap_state: 'visible') }
    after_initialize :set_default_sitemap_state
  end

  def sitemap_visible?
    sitemap_state == 'visible'
  end

  def sitemap_state_text
    SITEMAP_STATE_OPTIONS.rassoc(sitemap_state).try(:first)
  end

  private

  def set_default_sitemap_state
    self.sitemap_state ||= 'visible' if self.has_attribute?(:sitemap_state)
  end
end
