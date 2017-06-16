class GpCalendar::Publisher::HolidayCallbacks < PublisherCallbacks
  def enqueue(holiday)
    @holiday = holiday
    return unless enqueue?
    enqueue_nodes
    enqueue_pieces
  end

  private

  def enqueue_nodes
    Cms::Publisher.register(@holiday.content.site_id, @holiday.content.public_nodes)
  end

  def enqueue_pieces
    @holiday.content.public_pieces.each do |piece|
      Cms::Publisher::PieceCallbacks.new.enqueue(piece)
    end
  end
end
