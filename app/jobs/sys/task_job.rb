class Sys::TaskJob < ApplicationJob
  queue_as :sys_tasks
  queue_with_priority 10

  def perform(task_id)
    task = Sys::Task.find_by(id: task_id)
    ::Script.run('sys/tasks/exec', site_id: task.site_id) if task
  end
end
