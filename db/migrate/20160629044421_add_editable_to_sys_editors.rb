class AddEditableToSysEditors < ActiveRecord::Migration
  def up
    add_reference :sys_editors, :editable, index: true, polymorphic: true
    GpArticle::Doc.find_each {|d| d.editors << Sys::Editor.find_by(parent_unid: d.unid) }
  end

  def down
    remove_reference :sys_editors, :editable, index: true, polymorphic: true
  end
end
