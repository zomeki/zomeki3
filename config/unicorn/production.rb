rails_root = File.expand_path('../../../', __FILE__)

rails_env = ENV['RAILS_ENV'] || "production"

ENV['BUNDLE_GEMFILE'] = rails_root + "/Gemfile"

working_directory rails_root

timeout 300

preload_app true

worker_processes Integer(ENV["WEB_CONCURRENCY"] || 2)

# listen 8080, backlog: 1024
listen "/var/www/zomeki_pids/unicorn.sock", backlog: 1024

pid "/var/www/zomeki_pids/unicorn.pid"

stderr_path "#{rails_root}/log/#{rails_env}_unicorn_stderr.log"
stdout_path "#{rails_root}/log/#{rails_env}_unicorn_stdout.log"

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and
      ActiveRecord::Base.connection.disconnect!

  old_pid = "#{server.config[:pid]}.oldbin"
  if old_pid != server.pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
end
