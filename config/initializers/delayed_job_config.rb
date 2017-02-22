Delayed::Worker.max_run_time = 1.days
Delayed::Worker.read_ahead = 1

class Delayed::Plugins::CoreInitializer < Delayed::Plugin
  callbacks do |lifecycle|
    lifecycle.before(:execute) do |worker|
      Core.initialize
    end
  end
end
Delayed::Worker.plugins << Delayed::Plugins::CoreInitializer

class Delayed::Plugins::OomChecker < Delayed::Plugin
  callbacks do |lifecycle|
    lifecycle.after(:perform) do |worker|
      mem = GetProcessMem.new
      if mem.mb > 512
        worker.say "restart worker process because of large memory consumption: #{mem.mb.to_i} MB."
        worker.stop
        worker_id = worker.name.scan(/delayed_job[.]{0,1}(\d*)/).flatten.first
        options = []
        options << "--identifier=#{worker_id}" if worker_id.present?
        options << "--queue=#{worker.queues.join(',')}" if worker.queues.present?
        system("./bin/delayed_job restart #{options.join(' ')} RAILS_ENV=#{Rails.env} &")
      end
    end
  end
end
Delayed::Worker.plugins << Delayed::Plugins::OomChecker
