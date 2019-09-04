class UpdateFormFileMaxSizeOnSurveyQuestions < ActiveRecord::Migration[5.0]
  def up
    Survey::Question.where('form_file_max_size > 10').each do |question|
      question.update_column(:form_file_max_size, 10)
    end
  end

  def down
  end
end
