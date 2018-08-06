class Cms::Reorg::InquiryService < ReorgService
  def initialize
    @model = Cms::Inquiry
  end

  def reorganize_group(group_map)
    make_group_id_map(group_map, column: :group_id).tap do |id_map|
      update_group(id_map, column: :group_id)
      group_map.each do |src, dst|
        destroy_duplicated_group(dst)
      end
    end
  end

  private

  def destroy_duplicated_group(group)
    types = @model.where(group_id: group.id)
                  .order(:inquirable_id, :inquirable_type)
                  .group(:inquirable_id, :inquirable_type)
                  .having(@model.arel_table[:group_id].count.gteq(2))
                  .pluck(:inquirable_id, :inquirable_type)

    types.each do |p_id, p_type|
      items = @model.where(group_id: group.id, inquirable_id: p_id, inquirable_type: p_type).order(:id)
      items[1..-1].each(&:destroy) if items.size > 1
    end
  end
end
