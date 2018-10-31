class CreateSysTempTexts < ActiveRecord::Migration[4.2]
  def change
    create_table :sys_temp_texts do |t|
      t.text :content

      t.timestamps
    end
  end
end
