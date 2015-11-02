class Tag::Tag < ActiveRecord::Base
  include Sys::Model::Base
  include Concerns::Tag::Tag::Preload

  # Content
  belongs_to :content, :foreign_key => :content_id, :class_name => 'Tag::Content::Tag'
  validates :content_id, presence: true

  # Proper
  has_and_belongs_to_many :docs, -> { order(display_published_at: :desc, published_at: :desc) },
    :class_name => 'GpArticle::Doc', :join_table => 'gp_article_docs_tag_tags',
    :after_add => :update_last_tagged_at, :after_remove => :update_last_tagged_at

  def public_uri=(uri)
    @public_uri = uri
  end

  def public_uri
    return @public_uri if @public_uri
    return '' unless node = content.tag_node
    @public_uri = "#{node.public_uri}#{CGI::escape(word)}/"
  end

  def public_path
    return '' if public_uri.blank?
    "#{content.public_path}#{public_uri}"
  end

  def public_smart_phone_path
    return '' if public_uri.blank?
    "#{content.public_path}/_smartphone#{public_uri}"
  end

  def preview_uri(site: ::Page.site, mobile: ::Page.mobile?, params: {})
    return nil unless public_uri
    params = params.map{|k, v| "#{k}=#{v}" }.join('&')
    path = "_preview/#{format('%08d', site.id)}#{mobile ? 'm' : ''}#{public_uri}#{params.present? ? "?#{params}" : ''}"

    d = Cms::SiteSetting::AdminProtocol.core_domain site, site.full_uri, :freeze_protocol => true
    "#{d}#{path}"
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

  def public_docs
    docs.mobile(::Page.mobile?).public_state
  end

  def update_last_tagged_at(doc=nil)
    update_column(:last_tagged_at, Time.now)
  end
end
