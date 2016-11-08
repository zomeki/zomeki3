class Feed::Script::FeedEntriesController < Cms::Controller::Script::Publication
  def publish
    uri = @node.public_uri.to_s
    path = @node.public_path.to_s
    smart_phone_path = @node.public_smart_phone_path.to_s
    publish_page(@node, uri: "#{uri}index.rss", path: "#{path}index.rss", dependent: :rss)
    publish_page(@node, uri: "#{uri}index.atom", path: "#{path}index.atom", dependent: :atom)
    publish_more(@node, uri: uri, path: path, smart_phone_path: smart_phone_path, dependent: uri)

    render plain: 'OK'
  rescue => e
    error_log e.message
    render plain: e.message
  end
end
