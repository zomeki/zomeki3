class AddFileAttachableToSysFiles < ActiveRecord::Migration
  KLASSES = [
    GpArticle::Doc,
    GpCalendar::Event,
    GpCalendar::Holiday,
    Map::Marker,
  ]

  def up
    add_reference :sys_files, :file_attachable, index: true, polymorphic: true
    KLASSES.each do |klass|
      klass.find_each do |object|
        files = Sys::File.where(parent_unid: object.unid)
        object.files = files.each(&:skip_upload)
      end
    end
  end

  def down
    remove_reference :sys_files, :file_attachable, index: true, polymorphic: true
  end
end
