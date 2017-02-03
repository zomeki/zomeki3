class Feed::Tool::FeedsScript < Cms::Script::Base
  def rebuild
    content = Feed::Content::Feed.find(params[:content_id])
    return unless content

    content.public_nodes.each do |node|
      script_klass = node.script_klass
      script_klass.new(node_id: node.id).publish if script_klass && script_klass.publishable?
    end
  end
end
