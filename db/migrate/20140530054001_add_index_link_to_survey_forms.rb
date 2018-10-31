class AddIndexLinkToSurveyForms < ActiveRecord::Migration[4.2]
  def change
    add_column :survey_forms, :index_link, :string
  end
end
