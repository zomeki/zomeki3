class Cms::Node::SitemapsScript < PublicationScript
  def publish
    publish_page(@node, uri: @node.public_uri,
                        path: @node.public_path,
                        smart_phone_path: @node.public_smart_phone_path)
  end
end
