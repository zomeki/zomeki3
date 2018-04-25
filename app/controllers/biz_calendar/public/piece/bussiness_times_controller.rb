class BizCalendar::Public::Piece::BussinessTimesController < BizCalendar::Public::PieceController
  def pre_dispatch
    @piece = BizCalendar::Piece::BussinessTime.find(Page.current_piece.id)
    @item = Page.current_item
  end

  def index
    node = @piece.content.public_nodes.first!

    unless @piece.page_filter == 'through'
      if @item.class.to_s == "BizCalendar::Place"
        @place_name = @item.url
      end
    end

    @biz_calendar_node_uri = node.public_uri
  end
end
