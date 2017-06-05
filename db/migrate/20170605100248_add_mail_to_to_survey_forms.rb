class AddMailToToSurveyForms < ActiveRecord::Migration[5.0]
  def change
    add_column :survey_forms, :mail_to, :string
  end
end
