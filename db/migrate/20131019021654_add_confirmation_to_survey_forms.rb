class AddConfirmationToSurveyForms < ActiveRecord::Migration[4.2]
  def change
    add_column :survey_forms, :confirmation, :boolean
  end
end
