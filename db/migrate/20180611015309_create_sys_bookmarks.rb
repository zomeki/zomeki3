class CreateSysBookmarks < ActiveRecord::Migration[5.0]
  def change
    create_table :sys_bookmarks do |t|
      t.references :user
      t.references :parent
      t.string     :title
      t.string     :url
      t.integer    :level_no
      t.integer    :sort_no
      t.timestamps
    end
  end
end
