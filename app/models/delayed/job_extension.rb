class Delayed::JobExtension < Delayed::Job
  has_one :task, class_name: 'Sys::Task', foreign_key: :provider_job_id

  nested_scope :in_site, through: :task

  scope :with_global_id, ->(global_id) {
    where(arel_table[:handler].matches("%globalid: #{global_id}%"))
  }
end
