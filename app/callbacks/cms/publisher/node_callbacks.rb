class Cms::Publisher::NodeCallbacks < PublisherCallbacks
  def after_save(node)
    @node = node
    enqueue if enqueue?
  end

  def enqueue(node = nil)
    @node = node if node
    enqueue_nodes
  end

  private

  def enqueue?
    @node.name.present? && @node.state == 'public' && !@node.model.in?(%w(Cms::Page Cms::Directory Cms::SiteMap))
  end

  def enqueue_nodes
    Cms::Publisher.register(@node.site_id, @node)
  end
end
