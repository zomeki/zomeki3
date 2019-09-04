class AddMailAttachmentToSurveyForms < ActiveRecord::Migration[5.0]
  def up
    add_column :survey_forms, :mail_attachment, :boolean, :default => false
  end
  
  def down
    remove_column :survey_forms, :mail_attachment
  end
end
