class GpCategory::DocsScript < PublicationScript
  def publish
    uri  = @node.public_uri.to_s
    path = @node.public_path.to_s
    smart_phone_path = @node.public_smart_phone_path.to_s
    publish_page(@node, uri: "#{uri}index.rss", path: "#{path}index.rss", dependent: :rss)
    publish_page(@node, uri: "#{uri}index.atom", path: "#{path}index.atom", dependent: :atom)
    publish_more(@node, uri: uri, path: path, smart_phone_path: smart_phone_path)

    if @node.layout
      feed_piece_ids = @node.layout.pieces.select{|piece| piece.model == 'GpCategory::Feed'}.map(&:id)
      @feed_pieces = GpCategory::Piece::Feed.where(id: feed_piece_ids).all
      @feed_pieces.each do |piece|
        rss = piece.public_feed_uri('rss')
        atom = piece.public_feed_uri('atom')
        publish_page(@node, uri: "#{uri}#{rss}", path: "#{path}#{rss}", dependent: rss)
        publish_page(@node, uri: "#{uri}#{atom}", path: "#{path}#{atom}", dependent: atom)
      end
    end
  end
end
