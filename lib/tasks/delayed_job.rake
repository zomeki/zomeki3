namespace :delayed_job do
  def delayed_job
    "RAILS_ENV=#{Rails.env} bin/delayed_job"
  end

  def delayed_job_queue
    queues = {
      'sys_tasks' => task_worker_num,
      'default,cms_rebuild' => rebuild_worker_num,
      'cms_publisher' => publisher_worker_num,
      'cms_file_transfer' => file_transfer_worker_num
    }
    queues.select { |queue, num| num > 0 }
  end

  def delayed_job_pool_option
    delayed_job_queue.map { |queue, num| "--pool=#{queue}:#{num}" }.join(' ')
  end

  def delayed_job_options
    delayed_job_queue.map { |queue, num| ["--queue=#{queue}"] * num }.flatten
  end

  def delayed_job_pids
    delayed_job_options.map.with_index do |_, i|
      file = "#{Rails.root}/tmp/pids/delayed_job.#{i}.pid"
      File.read(file).to_i if File.exist?(file)
    end
  end

  def task_worker_num
    (ENV['TASK_WORKERS'] || 1).to_i
  end

  def rebuild_worker_num
    (ENV['REBUILD_WORKERS'] || 1).to_i
  end

  def publisher_worker_num
    (ENV['PUBLISHER_WORKERS'] || 1).to_i
  end

  def file_transfer_worker_num
    default = Zomeki.config.application['cms.file_transfer'] ? 1 : 0
    (ENV['FILE_TRANSFER_WORKERS'] || default).to_i
  end

  desc 'Start delayed job'
  task start: :environment do
    sh "#{delayed_job} start #{delayed_job_pool_option}"
  end

  desc 'Stop delayed job'
  task stop: :environment do
    sh "#{delayed_job} stop #{delayed_job_pool_option}"
  end

  desc 'Restart delayed job'
  task restart: :environment do
    sh "#{delayed_job} restart #{delayed_job_pool_option}"
  end

  desc 'Check delayed job status'
  task status: :environment do
    sh "#{delayed_job} status #{delayed_job_pool_option}"
  end

  desc 'Monitor delayed job'
  task monitor: :environment do
    pids = delayed_job_pids
    next Rake::Task['delayed_job:restart'].invoke if pids.compact.blank?
    ps = `ps uh --pid #{pids.compact.join(',')}`.split("\n").map { |line| line.split[1].to_i }
    next Rake::Task['delayed_job:restart'].invoke if ps.size == 0

    pids.each_with_index do |pid, i|
      if pid.nil? || !ps.include?(pid)
        sh "#{delayed_job} restart #{delayed_job_options[i]} --identifier=#{i}"
      end
    end
  end
end
