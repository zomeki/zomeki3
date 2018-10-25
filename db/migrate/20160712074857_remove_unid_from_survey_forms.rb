class RemoveUnidFromSurveyForms < ActiveRecord::Migration[4.2]
  def change
    remove_column :survey_forms, :unid, :integer
  end
end
