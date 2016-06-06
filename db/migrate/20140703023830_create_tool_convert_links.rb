class CreateToolConvertLinks < ActiveRecord::Migration
  def up
    create_table :tool_convert_links do |t|
      t.belongs_to :concept
      t.belongs_to :linkable, polymorphic: true
      t.text       :urls
      t.text       :before_body
      t.text       :after_body
      t.timestamps
    end
  end

  def down
    drop_table :tool_convert_links
  end
end
