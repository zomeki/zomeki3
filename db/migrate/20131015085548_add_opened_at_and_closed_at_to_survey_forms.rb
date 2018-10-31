class AddOpenedAtAndClosedAtToSurveyForms < ActiveRecord::Migration[4.2]
  def change
    add_column :survey_forms, :opened_at, :datetime
    add_column :survey_forms, :closed_at, :datetime
  end
end
