class AddRecognizableToSysRecognitions < ActiveRecord::Migration
  def up
    add_column :sys_recognitions, :recognizable_id, :integer
    add_column :sys_recognitions, :recognizable_type, :string
    add_index :sys_recognitions, [:recognizable_type, :recognizable_id], name: 'index_sys_recognitions_on_recognizable'
    Sys::Recognition.find_each do |r|
      if unid = Sys::Unid.find_by(id: r.id)
        target = unid.model.constantize.find_by(id: unid.item_id)
        r.recognizable = target
        r.save
      end
    end
  end

  def down
    remove_index :sys_recognitions, name: 'index_sys_recognitions_on_recognizable'
    remove_column :sys_recognitions, :recognizable_type
    remove_column :sys_recognitions, :recognizable_id
  end
end
