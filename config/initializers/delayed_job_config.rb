Delayed::Worker.max_run_time = 1.days
Delayed::Worker.read_ahead = 1

Delayed::Worker.lifecycle.after(:execute) do |worker|
  Core.initialize
end
