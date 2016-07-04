class AddMapAttachableToCmsMaps < ActiveRecord::Migration
  KLASSES = [
    GpArticle::Doc,
  ]

  def up
    add_reference :cms_maps, :map_attachable, index: true, polymorphic: true
    KLASSES.each do |klass|
      klass.find_each {|o| o.maps = Cms::Map.where(unid: o.unid) }
    end
  end

  def down
    remove_reference :cms_maps, :map_attachable, index: true, polymorphic: true
  end
end
