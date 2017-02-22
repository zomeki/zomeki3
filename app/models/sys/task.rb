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

  def unnecessary?
    return true unless processable
    return false unless processable.respond_to?(:state)
    (publish_task? && processable.state.in?(%w(public closed finish))) || (close_task? && processable.state.in?(%w(closed finish)))
  end

  def set_queue
    Sys::TaskJob.set(wait_until: self.process_at).perform_later(id)
  end

  class << self
    def cleanup
      tasks = self.where(self.arel_table[:process_at].lt(Time.now - 3.months))
                  .preload(:processable)
      tasks.find_each do |task|
        task.destroy if task.unnecessary?
      end
    end
  end
end
