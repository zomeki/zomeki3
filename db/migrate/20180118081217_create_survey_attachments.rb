class CreateSurveyAttachments < ActiveRecord::Migration[5.0]
  def change
    create_table :survey_attachments do |t|
      t.references  :site
      t.references  :answer
      t.string      :name
      t.text        :title
      t.text        :mime_type
      t.integer     :size
      t.integer     :image_is
      t.integer     :image_width
      t.integer     :image_height
      t.binary      :data
      t.integer     :thumb_width
      t.integer     :thumb_height
      t.integer     :thumb_size
      t.binary      :thumb_data
      t.timestamps
    end
  end
end
