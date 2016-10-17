class Tag::Script::TagsController < Cms::Controller::Script::Publication
  def publish
    publish_more(@node, uri: @node.public_uri, path: @node.public_path,
                        smart_phone_path: @node.public_smart_phone_path, dependent: @node.public_uri,
                        limit: 0)

    tags = @node.content.tags
    tags = tags.where(id: params[:target_tag_id]) if params[:target_tag_id].present? 
    tags.each do |tag|
      next if tag.public_docs.blank?
      publish_more(@node, uri: tag.public_uri, path: CGI::unescape(tag.public_path),
                          smart_phone_path: CGI::unescape(tag.public_smart_phone_path), dependent: tag.public_uri)
    end

    render plain: 'OK'
  rescue => e
    error_log e.message
    render plain: e.message
  end
end
