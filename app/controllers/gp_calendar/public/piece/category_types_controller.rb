class GpCalendar::Public::Piece::CategoryTypesController < GpCalendar::Public::Piece::BaseController
  def pre_dispatch
    @piece = GpCalendar::Piece::CategoryType.find(Page.current_piece.id)
    @item = Page.current_item
  end

  def index
    @target_node_public_uri = @piece.target_node.try(:public_uri).to_s

    if @target_node_public_uri.blank?
      return render plain: '' unless %w!GpCalendar::Event
                                        GpCalendar::TodaysEvent
                                        GpCalendar::CalendarStyledEvent!.include?(@item.model)
    end

    @category_types = @piece.content.public_category_types
  end
end
