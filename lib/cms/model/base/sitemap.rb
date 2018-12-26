module Cms::Model::Base::Sitemap
  extend ActiveSupport::Concern

  included do
    enum_ish :sitemap_state, [:visible, :hidden], default: :visible, predicate: true
    scope :visible_in_sitemap, -> { where(sitemap_state: 'visible') }
    after_save     Cms::Publisher::SitemapCallbacks.new, if: :saved_changes?
    before_destroy Cms::Publisher::SitemapCallbacks.new, prepend: true
  end
end
