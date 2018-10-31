class AddNoteToCmsContents < ActiveRecord::Migration[4.2]
  def change
    add_column :cms_contents, :note, :string
  end
end
