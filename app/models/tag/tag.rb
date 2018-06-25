class Tag::Tag < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Base::Page
  include Cms::Model::Rel::Content

  # Content
  belongs_to :content, class_name: 'Tag::Content::Tag', required: true

  # Proper
  has_and_belongs_to_many :docs, -> { order(display_published_at: :desc, published_at: :desc) },
                                 class_name: 'GpArticle::Doc',
                                 join_table: 'gp_article_docs_tag_tags',
                                 after_add: :update_last_tagged_at,
                                 after_remove: :update_last_tagged_at

  def public_uri
    return unless node = content.node
    "#{node.public_uri}#{ERB::Util.url_encode(word)}/"
  end

  def bread_crumbs(tag_node)
    crumbs = []

    crumb = tag_node.bread_crumbs.crumbs.first
    crumb << [word, "#{tag_node.public_uri}#{CGI::escape(word)}/"]
    crumbs << crumb

    if crumbs.empty?
      tag_node.routes.each do |r|
        crumb = []
        r.each {|r| crumb << [r.title, r.public_uri] }
        crumbs << crumb
      end
    end

    Cms::Lib::BreadCrumbs.new(crumbs)
  end

  def update_last_tagged_at(doc=nil)
    update_column(:last_tagged_at, Time.now)
  end

  class << self
    def split_raw_string(str)
      str = Moji.normalize_zen_han(str).downcase
      str.split(/"([^"]*)"|[ 　,、，]+/).select(&:present?).uniq
    end
  end
end
