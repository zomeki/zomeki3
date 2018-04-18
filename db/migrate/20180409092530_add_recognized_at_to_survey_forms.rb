class AddRecognizedAtToSurveyForms < ActiveRecord::Migration[5.0]
  def change
    add_column :survey_forms, :recognized_at, :datetime
  end
end
