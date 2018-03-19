class BizCalendar::Public::Piece::BussinessTimesController < BizCalendar::Public::Piece::BaseController
  def pre_dispatch
    @piece = BizCalendar::Piece::BussinessTime.find_by(id: Page.current_piece.id)
    return render plain: '' unless @piece

    @item = Page.current_item
  end

  def index
    node = @piece.content.public_nodes.first
    return render plain: '' unless node

    unless @piece.page_filter == 'through'
      if @item.class.to_s == "BizCalendar::Place"
        @place_name = @item.url
      end
    end

    @biz_calendar_node_uri = node.public_uri
  end
end
