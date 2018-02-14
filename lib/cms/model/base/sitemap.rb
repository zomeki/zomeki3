module Cms::Model::Base::Sitemap
  extend ActiveSupport::Concern

  included do
    enum_ish :sitemap_state, [:visible, :hidden], default: :visible
    scope :visible_in_sitemap, -> { where(sitemap_state: 'visible') }
    after_save     Cms::Publisher::SitemapCallbacks.new, if: :changed?
    before_destroy Cms::Publisher::SitemapCallbacks.new
  end

  def sitemap_visible?
    sitemap_state == 'visible'
  end
end
