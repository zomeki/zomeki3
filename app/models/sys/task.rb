class Sys::Task < ApplicationRecord
  include Sys::Model::Base

  belongs_to :processable, polymorphic: true

  after_save :set_queue , if: :close_task?

  def publish_task?
    name == 'publish'
  end

  def close_task?
    name == 'close'
  end

  def set_queue
    Sys::TaskJob.set(wait_until: self.process_at).perform_later(id)
  end
end
