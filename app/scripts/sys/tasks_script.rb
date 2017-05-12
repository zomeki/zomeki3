class Sys::TasksScript < Cms::Script::Base
  def exec
    processable_task_ids do |task_ids|
      tasks = Sys::Task.where(id: task_ids).order(process_at: :desc)

      ::Script.total tasks.size

      tasks.each do |task|
        unless task.processable
          task.destroy
          ::Script.error "Processable Not Found"
          next
        end

        begin
          script_klass = "#{task.processable_type.pluralize}Script".constantize
          processed = script_klass.new(params.merge(task: task)).public_send("#{task.name}_by_task", task.processable)
          task.update_attributes(state: 'performed') if processed
        rescue => e
          ::Script.error e
          info_log "Error: #{e}"
          puts "Error: #{e}"
        end
      end
    end
  end

  private

  def processable_task_ids
    task_ids = []
    Sys::Task.transaction do
      tasks = Sys::Task.queued_items
                       .where(Sys::Task.arel_table[:process_at].lteq(Time.now)).lock
      tasks = tasks.where(site_id: ::Script.site.id) if ::Script.site
      task_ids = tasks.pluck(:id)
      Sys::Task.where(id: task_ids).update_all(state: 'performing')
    end
    yield task_ids
  ensure
    Sys::Task.where(id: task_ids, state: 'performing').update_all(state: 'queued')
  end
end
