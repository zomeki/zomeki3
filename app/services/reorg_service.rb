class ReorgService < ApplicationService
  attr_reader :model

  def reorganize_group(group_map)
  end

  def reorganize_user(user_map)
  end

  private

  def make_group_id_map(group_map, column: :group_id)
    group_map.each_with_object({}) do |(src, dst), id_map|
      ids = @model.where(column => src.id).order(:id).pluck(:id)
      id_map[[src, dst]] = ids if ids.present?
    end
  end

  def update_group(id_map, column: :group_id)
    id_map.each do |(src, dst), ids|
      @model.where(id: ids).update_all(column => dst.id)
    end
  end

  def make_user_id_map(user_map, column: :user_id)
    user_map.each_with_object({}) do |(src, dst), id_map|
      ids = @model.where(column => src.id).order(:id).pluck(:id)
      id_map[[src, dst]] = ids if ids.present?
    end
  end

  def update_user(id_map, column: :user_id)
    id_map.each do |(src, dst), ids|
      @model.where(id: ids).update_all(column => dst.id)
    end
  end
end
