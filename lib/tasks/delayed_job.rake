namespace :delayed_job do
  def delayed_job
    "RAILS_ENV=#{Rails.env} bin/delayed_job"
  end

  def delayed_job_options
    "--pool=sys_tasks:1 --pool=cms_rebuild:1 --pool=*:#{pool_size}"
  end

  def pool_size
    (ENV['DELAYED_JOB_POOL_SIZE'] || 1).to_i
  end

  def max_memory
    (ENV['DELAYED_JOB_MAX_MEMORY'] || 1024**2).to_i
  end

  def start
    sh "#{delayed_job} start #{delayed_job_options}"
  end

  def stop
    sh "#{delayed_job} stop #{delayed_job_options}"
  end

  def restart
    sh "#{delayed_job} restart #{delayed_job_options}"
  end

  def status
    sh "#{delayed_job} status #{delayed_job_options}"
  end

  def delayed_job_pids
    Dir["#{Rails.root}/tmp/pids/delayed_job*.pid"].map do |file|
      File.read(file).to_i
    end
  end

  def delayed_job_running?
    Delayed::Job.where.not(locked_at: nil).exists?
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
    pids = delayed_job_pids
    procs = `ps uh --pid #{pids.join(',')}`.split("\n").map(&:split)
    if procs.size == 0
      start
    elsif procs.size < pids.size && !delayed_job_running?
      restart
    else
      mems = procs.map { |p| p[5].to_i }
      if mems.any? { |mem| mem > max_memory } && !delayed_job_running?
        restart
      end
    end
  end

  desc 'Check delayed job status'
  task status: :environment do
    status
  end
end
