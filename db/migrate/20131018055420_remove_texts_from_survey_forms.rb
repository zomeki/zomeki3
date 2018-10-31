class RemoveTextsFromSurveyForms < ActiveRecord::Migration[4.2]
  def up
    remove_column :survey_forms, :upper_text
    remove_column :survey_forms, :lower_text
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
