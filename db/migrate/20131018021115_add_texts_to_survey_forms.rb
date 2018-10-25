class AddTextsToSurveyForms < ActiveRecord::Migration[4.2]
  def change
    add_column :survey_forms, :summary, :text
    add_column :survey_forms, :description, :text
    add_column :survey_forms, :receipt, :text
  end
end
