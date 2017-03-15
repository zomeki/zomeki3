class GpCalendar::Publisher::HolidayCallbacks < PublisherCallbacks
  def after_save(holiday)
    @holiday = holiday
    enqueue if enqueue?
  end

  def before_destroy(holiday)
    @holiday = holiday
    enqueue if enqueue?
  end

  def enqueue(holiday = nil)
    @holiday = holiday if holiday
    enqueue_nodes
    enqueue_pieces
  end

  private

  def enqueue?
    true
  end

  def enqueue_nodes
    Cms::Publisher.register(@holiday.content.site_id, @holiday.content.public_nodes.select(:id, :parent_id, :name))
  end

  def enqueue_pieces
    @holiday.content.public_pieces.each do |piece|
      Cms::Publisher::PieceCallbacks.new.enqueue(piece)
    end
  end
end
