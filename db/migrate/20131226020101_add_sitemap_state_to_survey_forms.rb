class AddSitemapStateToSurveyForms < ActiveRecord::Migration[4.2]
  def change
    add_column :survey_forms, :sitemap_state, :string
  end
end
