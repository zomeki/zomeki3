class AddFormTextMaxLengthToSurveyQuestions < ActiveRecord::Migration[4.2]
  def change
    add_column :survey_questions, :form_text_max_length, :integer
  end
end
