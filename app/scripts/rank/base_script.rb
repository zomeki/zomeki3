class Rank::BaseScript < PublicationScript
  def publish
    publish_more(@node, uri: @node.public_uri,
                        path: @node.public_path,
                        smart_phone_path: @node.public_smart_phone_path)
  end
end
