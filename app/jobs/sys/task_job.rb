class Sys::TaskJob < ApplicationJob
  queue_as :sys_tasks

  def perform(record_id)
    ::Script.run('sys/script/tasks/exec', {record_id: record_id})
  end
end
