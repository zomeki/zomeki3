module Sys::Model::Rel::Task
  extend ActiveSupport::Concern

  included do
    has_many :tasks, class_name: 'Sys::Task', dependent: :destroy, as: :processable
    accepts_nested_attributes_for :tasks

    before_save :prepare_tasks, if: -> { @tasks_attributes_changed }
    after_save :enqueue_tasks, if: -> { state.in?(%w(recognized approved prepared public)) }

    scope :with_task_name, ->(name) {
      tasks = Sys::Task.arel_table
      joins(:tasks).where(tasks[:name].eq(name))
    }
  end

  def queued_tasks
    tasks.where(state: 'queued')
  end

  def task_for_form(name)
    task = tasks.detect { |t| t.name == name } || tasks.build(name: name)
    task.process_at = nil if task.state_performed?
    task
  end

  def tasks_attributes=(val)
    @tasks_attributes_changed = true
    super
  end

  def enqueue_tasks
    queued_tasks.each(&:enqueue_job)
  end

  private

  def prepare_tasks
    @tasks_attributes_changed = false
    tasks.each do |task|
      task.state = 'queued'
      task.site_id = site.id if site
      task.mark_for_destruction if task.name.blank? || task.process_at.blank?
    end
  end
end
