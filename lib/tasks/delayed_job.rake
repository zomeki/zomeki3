namespace :delayed_job do
  desc "Start delayed_job"
  task start: :environment do
    sh "bundle exec bin/delayed_job_master -c #{delayed_job_config_file} -D RAILS_ENV=#{Rails.env}"
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

  def delayed_job_config_file
    Rails.root.join("config/delayed_job/delayed_job_master.rb").to_s
  end

  def delayed_job_config
    require 'delayed/master'
    dsl = Delayed::Master::DSL.new(delayed_job_config_file)
    dsl.config
  end

  def delayed_job_signal(signal)
    Process.kill(signal, delayed_job_pid)
  end

  def delayed_job_pid
    begin
      File.read(delayed_job_config[:pid_file]).to_i
    rescue Errno::ENOENT
      raise "Delayed_job doesn't seem to be running"
    end
  end
end
