class Cms::Publisher::NodeCallbacks < PublisherCallbacks
  def enqueue(node)
    @node = node
    return unless enqueue?
    enqueue_nodes
  end

  private

  def enqueue?
    return unless super
    @node.name.present? && [@node.state, @node.state_was].include?('public')
  end

  def enqueue_nodes
    return if @node.model.in?(%w(Cms::Page Cms::Directory Cms::Sitemap))
    Cms::Publisher.register(@node.site_id, @node)
  end
end
