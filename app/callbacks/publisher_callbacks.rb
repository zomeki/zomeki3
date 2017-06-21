class PublisherCallbacks < ApplicationCallbacks
  def after_save(item)
    enqueue(item)
  end

  def before_destroy(item)
    enqueue(item)
  end

  def enqueue(item)
  end

  private

  def enqueue?
    Zomeki.config.application['cms.file_publisher'] != false
  end
end
