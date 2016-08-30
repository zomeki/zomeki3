class ApplicationJob < ActiveJob::Base
  class << self
    def queued?
      Delayed::Job.where(queue: queue_name, locked_at: nil).exists?
    end
  end
end
