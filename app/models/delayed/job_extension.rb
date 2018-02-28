class Delayed::JobExtension < Delayed::Job
  has_one :task, class_name: 'Sys::Task', foreign_key: :provider_job_id

  nested_scope :in_site, through: :task
end
