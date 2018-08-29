class Sys::Reorg::EditorService < ReorgService
  def initialize
    @model = Sys::Editor
  end

  def reorganize_group(group_map)
    make_group_id_map(group_map, column: :group_id).tap do |id_map|
      update_group(id_map, column: :group_id)
    end
  end
end
