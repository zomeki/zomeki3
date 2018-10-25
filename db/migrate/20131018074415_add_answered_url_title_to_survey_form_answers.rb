class AddAnsweredUrlTitleToSurveyFormAnswers < ActiveRecord::Migration[4.2]
  def change
    add_column :survey_form_answers, :answered_url_title, :string
  end
end
