namespace :delayed_job do
  desc "Start delayed_job"
  task start: :environment do
    config = "#{Rails.root}/config/delayed_job/delayed_job_master.rb"
    sh "bundle exec bin/delayed_job_master -c #{config} -D RAILS_ENV=#{Rails.env}"
  end

  desc "Stop delayed_job"
  task stop: :environment do
    delayed_job_signal :TERM
  end

  desc "Quit delayed_job"
  task quit: :environment do
    delayed_job_signal :QUIT
  end

  desc "Restart delayed_job with USR2"
  task restart: :environment do
    delayed_job_signal :USR2
  end

  desc "Reopen log files with USR1"
  task reopen_files: :environment do
    delayed_job_signal :USR1
  end

  def delayed_job_signal(signal)
    Process.kill(signal, delayed_job_pid)
  end

  def delayed_job_pid
    begin
      File.read("#{Rails.root}/tmp/pids/delayed_job_master.pid").to_i
    rescue Errno::ENOENT
      raise "Delayed_job doesn't seem to be running"
    end
  end
end
