class CreateSysObjectRelations < ActiveRecord::Migration
  def change
    create_table :sys_object_relations do |t|
      t.belongs_to :source, index: true, polymorphic: true
      t.belongs_to :related, index: true, polymorphic: true
      t.string :relation_type
    end
  end
end
