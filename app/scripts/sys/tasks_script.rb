class Sys::TasksScript < Cms::Script::Base
  def exec
    tasks = Sys::Task.order(process_at: :desc).preload(:processable)
    tasks = tasks.where(site_id: Script.options[:site_id]) if Script.options && Script.options[:site_id]
    tasks = tasks.where(Sys::Task.arel_table[:process_at].lteq(Time.now))

    ::Script.total tasks.size

    return if tasks.empty?

    tasks.each do |task|
      begin
        unless task.processable
          task.destroy
          raise 'Processable Not Found'
        end

        script_klass = "#{task.processable_type.pluralize}Script".constantize
        script_klass.new(params.merge(task: task, item: task.processable)).public_send("#{task.name}_by_task")
      rescue => e
        ::Script.error e
        info_log "Error: #{e}"
        puts "Error: #{e}"
      end
    end
  end
end
