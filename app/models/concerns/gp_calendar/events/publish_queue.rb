module GpCalendar::Events::PublishQueue
  extend ActiveSupport::Concern

  included do
    after_save :enqueue_publisher_callback, if: :changed?
    before_destroy :enqueue_publisher_callback
  end

  def enqueue_publisher
    enqueue_publisher_for_node
    enqueue_publisher_for_piece
  end

  private

  def enqueue_publisher_callback
    enqueue_publisher if enqueue_publisher?
  end

  def enqueue_publisher?
    true
  end

  def enqueue_publisher_for_node
    changed_dates = [started_on, started_on_was, ended_on, ended_on_was].compact.uniq
    min_date = changed_dates.min.beginning_of_month
    max_date = changed_dates.max.beginning_of_month

    Cms::Publisher.register(content.site_id, content.public_nodes.select(:id), 
      target_min_date: min_date.strftime('%Y-%m-%d'),
      target_max_date: max_date.strftime('%Y-%m-%d')
    )
  end

  def enqueue_publisher_for_piece
    content.public_pieces.each do |piece|
      piece.enqueue_publisher
    end
  end
end
