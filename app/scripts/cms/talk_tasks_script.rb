require 'digest/md5'
class Cms::TalkTasksScript < Cms::Script::Publication
  def exec
    task_ids = Cms::TalkTask.order(:id)
    task_ids = task_ids.where(site_id: ::Script.site.id) if ::Script.site
    task_ids = task_ids.pluck(:id)

    ::Script.total task_ids.size

    task_ids.each do |task_id|
      task = Cms::TalkTask.find_by(id: task_id)
      next unless task

      ::Script.progress(task) do
        result = task.exec
        task.destroy
        raise "MakeSoundError" unless result
      end
    end
  end
end
