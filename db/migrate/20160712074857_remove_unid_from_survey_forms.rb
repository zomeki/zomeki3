class RemoveUnidFromSurveyForms < ActiveRecord::Migration
  def change
    remove_column :survey_forms, :unid, :integer
  end
end
