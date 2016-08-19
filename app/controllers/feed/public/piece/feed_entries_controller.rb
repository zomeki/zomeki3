class Feed::Public::Piece::FeedEntriesController < Sys::Controller::Public::Base

  def pre_dispatch
    @piece = Feed::Piece::FeedEntry.find_by(id: Page.current_piece.id)
    return render(text: '') unless @piece
    
    @item = Page.current_item
  end

  def index
    @content = Feed::Content::Feed.find(Page.current_piece.content_id)

    item = @content.public_entries
    
    list_type = nil
    list_html = ''
    page_html = nil

    @node = @content.public_node
    @node_uri = @node.public_uri if @node

    @entries = item.limit(@piece.docs_number)

    prev   = nil
    @items = []
    @entries.each do |entry|
      date = entry.entry_updated.strftime('%y%m%d')
      @items << {
        :date => (date != prev ? entry.entry_updated.strftime('%Y年%-m月%-d日') : nil),
        :entry  => entry
      }
      prev = date
    end
  end
end
