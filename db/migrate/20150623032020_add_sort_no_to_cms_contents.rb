class AddSortNoToCmsContents < ActiveRecord::Migration[4.2]
  def change
    add_column :cms_contents, :sort_no, :integer
  end
end
