rails_root = Dir.pwd
rails_env = ENV['RAILS_ENV'] || "production"

# working directory
working_directory rails_root

# monitor wait time in second
monitor_wait 5

# path to pid file
pid_file "#{rails_root}/tmp/pids/delayed_job_master.pid"

# path to log file
log_file "#{rails_root}/log/#{rails_env}_delayed_job_master.log"

# log level
log_level :info

# task
add_worker do |worker|
  worker.queues %w(sys_tasks)
  worker.control :dynamic
  worker.count (ENV['TASK_WORKERS'] || 1).to_i
  worker.max_memory 512
  worker.max_run_time 3600
  worker.read_ahead 1
end

# rebuild
add_worker do |worker|
  worker.queues %w(default cms_rebuild)
  worker.control :dynamic
  worker.count (ENV['REBUILD_WORKERS'] || 1).to_i
  worker.max_memory 512
  worker.max_run_time 24*3600
  worker.read_ahead 1
end

# publisher
add_worker do |worker|
  worker.queues %w(cms_publisher)
  worker.control :dynamic
  worker.count (ENV['PUBLISHER_WORKERS'] || 1).to_i
  worker.max_memory 512
  worker.max_run_time 24*3600
  worker.read_ahead 1
end

# file transfer
require 'yaml'
if YAML.load_file("#{rails_root}/config/application.yml").dig('cms', 'file_transfer')
  add_worker do |worker|
    worker.queues %w(cms_file_transfer)
    worker.control :dynamic
    worker.count (ENV['FILE_TRANSFER_WORKERS'] || 1).to_i
    worker.max_memory 512
    worker.max_run_time 3600
    worker.read_ahead 1
  end
end

before_fork do |master, worker_info|
  Delayed::Worker.before_fork if defined?(Delayed::Worker)
end

after_fork do |master, worker_info|
  Delayed::Worker.after_fork if defined?(Delayed::Worker)
end

before_monitor do |master|
  ActiveRecord::Base.connection.verify! if defined?(ActiveRecord::Base)
end

after_monitor do |master|
end
