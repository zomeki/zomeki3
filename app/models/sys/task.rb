class Sys::Task < ApplicationRecord
  include Sys::Model::Base

  belongs_to :processable, polymorphic: true
  belongs_to :provider_job, class_name: '::Delayed::Job', dependent: :destroy

  after_initialize :set_defaults

  scope :queued_items, -> {
    where([
      arel_table[:state].eq('queued'),
      [arel_table[:state].eq('performing'), arel_table[:updated_at].lt(1.hours.ago)].reduce(:and)
    ].reduce(:or))
  }

  def publish_task?
    name == 'publish'
  end

  def close_task?
    name == 'close'
  end

  def state_queued?
    state == 'queued'
  end

  def state_performed?
    state == 'performed'
  end

  def enqueue_job
    transaction do
      provider_job.destroy if provider_job
      job = Sys::TaskJob.set(wait_until: process_at).perform_later(id)
      update_columns(job_id: job.job_id, provider_job_id: job.provider_job_id)
    end
  end

  private

  def set_defaults
    self.state ||= 'queued' if has_attribute?(:state)
  end
end
