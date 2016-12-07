require 'open3'
namespace :delayed_job do
  def delayed_job
    "RAILS_ENV=#{Rails.env} bin/delayed_job"
  end

  def delayed_job_options
    pool_size = ENV['DELAYED_JOB_POOL_SIZE'] || 1
    "--pool=*:#{pool_size}  start--pool=tracking --pool=sys_tasks:1"
  end

  def start
    Open3.pipeline("#{delayed_job} start #{delayed_job_options}")
  end

  def stop
    Open3.pipeline("#{delayed_job} stop #{delayed_job_options}")
  end

  def restart
    Open3.pipeline("#{delayed_job} restart #{delayed_job_options}")
  end

  def status
    Open3.pipeline("#{delayed_job} status #{delayed_job_options}")
  end

  desc 'Start delayed job'
  task start: :environment do
    start
  end

  desc 'Stop delayed job'
  task stop: :environment do
    stop
  end

  desc 'Restart delayed job'
  task restart: :environment do
    restart
  end

  desc 'Monitor delayed job'
  task monitor: :environment do
    procs = `ps aux | grep delayed_job | grep -v grep | grep -v delayed_job:monitor`.split("\n").map(&:split)
    if procs.size == 0
      start
    else
      mems = procs.map {|p| p[5].to_i }
      if mems.any? {|mem| mem > 1024*1024 } && !Delayed::Job.where.not(locked_at: nil).exists?
        restart
      end
    end
  end

  desc 'Check delayed job status'
  task status: :environment do
    status
  end
end
