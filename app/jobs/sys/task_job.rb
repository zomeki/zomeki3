class Sys::TaskJob < ApplicationJob
  queue_as :sys_tasks

  def perform(record)
    Script.run('sys/script/tasks/exec', {record_id: record.id})
  end
end
