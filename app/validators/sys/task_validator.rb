class Sys::TaskValidator < ActiveModel::Validator
  def validate(record)
    publish_task = record.tasks.detect(&:publish_task?)
    close_task = record.tasks.detect(&:close_task?)

    if publish_task && publish_task.process_at && publish_task.process_at < Time.now
      record.errors.add(:base, '公開開始日時は現在日時より後の日時を入力してください。')
      publish_task.errors.add(:process_at)
    end

    if publish_task && close_task
      if publish_task.process_at && close_task.process_at && publish_task.process_at > close_task.process_at
        record.errors.add(:base, '公開開始日時は公開終了日時より前の日時を入力してください。')
        publish_task.errors.add(:process_at)
      end
    end
  end
end
