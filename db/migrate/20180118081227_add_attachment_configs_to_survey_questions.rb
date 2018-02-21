class AddAttachmentConfigsToSurveyQuestions < ActiveRecord::Migration[5.0]
  def change
    add_column :survey_questions, :form_file_max_size, :integer
    add_column :survey_questions, :form_file_extension, :string
  end
end
