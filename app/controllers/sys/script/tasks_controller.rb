class Sys::Script::TasksController < ApplicationController
  def exec
    tasks = Sys::Task.where(Sys::Task.arel_table[:process_at].lteq(3.minutes.since))
                     .order(:process_at).includes(:processable)
    tasks = tasks.where(site_id: Script.options[:site_id]) if Script.options && Script.options[:site_id]
    Script.total tasks.size

    return render plain: 'No Tasks' if tasks.empty?

    tasks.each do |task|
      begin
        unless task.processable
          task.destroy
          raise 'Processable Not Found'
        end

        item = task.processable
        model = item.class.name.underscore.pluralize
        model = 'cms/nodes' if model == 'cms/model/node/pages' # for v1.1.7

        ctl = model.gsub(/\A(.*?)\//, '\1/script/')
        act = "#{task.name}_by_task"
        prms = params.merge(task: task, item: item)

        render_component_into_view controller: ctl, action: act, params: prms
      rescue => e
        Script.error e
        puts "Error: #{e}"
      end
    end

    render plain: 'OK'
  end
end
