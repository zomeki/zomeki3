class AddEditableToSysEditableGroups < ActiveRecord::Migration
  KLASSES = [
    GpArticle::Doc,
  ]

  def up
    add_reference :sys_editable_groups, :editable, index: true, polymorphic: true
    KLASSES.each do |klass|
      klass.find_each {|o| o.editable_group ||= Sys::EditableGroup.find_by(id: o.unid) }
    end
  end

  def down
    remove_reference :sys_editable_groups, :editable, index: true, polymorphic: true
  end
end
