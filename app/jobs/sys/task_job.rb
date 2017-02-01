class Sys::TaskJob < ApplicationJob
  queue_as :sys_tasks
  queue_with_priority 10

  def perform(record_id)
    ::Script.run('sys/script/tasks/exec', {record_id: record_id})
  end
end
