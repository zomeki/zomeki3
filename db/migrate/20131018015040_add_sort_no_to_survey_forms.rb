class AddSortNoToSurveyForms < ActiveRecord::Migration[4.2]
  def change
    add_column :survey_forms, :sort_no, :integer
  end
end
