module Sys::Model::Rel::Task
  extend ActiveSupport::Concern

  included do
    has_many :tasks, class_name: 'Sys::Task', dependent: :destroy, as: :processable
    accepts_nested_attributes_for :tasks

    with_options if: :save_tasks? do
      before_save :prepare_tasks
      validate :validate_tasks, if: -> { state != 'draft' }
    end

    scope :with_task_name, ->(name) {
      tasks = Sys::Task.arel_table
      joins(:tasks).where(tasks[:name].eq(name))
    }
  end

  def tasks_attributes=(val)
    @save_tasks = true
    super
  end

  def save_tasks?
    @save_tasks
  end

  def set_queues
    return if tasks.blank?
    if state == 'recognized' || state == 'approved' || state == 'prepared'
      tasks.each{|t| t.set_queue if t.publish_task? }
    end
  end

  private

  def validate_tasks
    publish_task = tasks.detect(&:publish_task?)
    close_task = tasks.detect(&:close_task?)

    if publish_task && publish_task.process_at && publish_task.process_at < Time.now
      errors.add(:base, '公開開始日時は現在日時より後の日時を入力してください。')
      publish_task.errors.add(:process_at)
    end

    if publish_task && close_task
      if publish_task.process_at && close_task.process_at && publish_task.process_at > close_task.process_at
        errors.add(:base, '公開開始日時は公開終了日時より前の日時を入力してください。')
        publish_task.errors.add(:process_at)
      end
    end
  end

  def prepare_tasks
    tasks.each do |task|
      task.site_id = Core.site.id if Core.site
      task.mark_for_destruction if task.name.blank? || task.process_at.blank?
    end
  end

end
