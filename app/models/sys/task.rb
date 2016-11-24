class Sys::Task < ApplicationRecord
  include Sys::Model::Base

  after_save :set_queue
  belongs_to :processable, polymorphic: true

  def publish_task?
    name == 'publish'
  end

  def close_task?
    name == 'close'
  end

private

  def set_queue
    Sys::TaskJob.set(wait_until: self.process_at, priority: 10).perform_later(id)
  end

end
