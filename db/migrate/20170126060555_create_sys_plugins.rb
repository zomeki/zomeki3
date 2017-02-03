class CreateSysPlugins < ActiveRecord::Migration[5.0]
  def change
    create_table :sys_plugins do |t|
      t.string     :name
      t.string     :title
      t.string     :version
      t.string     :state
      t.text       :note
      t.integer    :sort_no
      t.timestamps null: false
    end
  end
end
