class Delayed::JobExtension < Delayed::Job
  include Cms::Model::Site

  has_one :task, class_name: 'Sys::Task', foreign_key: :provider_job_id

  define_site_scope :task
end
