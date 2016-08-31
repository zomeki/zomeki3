module Sys::Model::Rel::EditableGroup
  extend ActiveSupport::Concern

  included do
    has_one :editable_group, class_name: 'Sys::EditableGroup', dependent: :destroy, as: :editable
    after_save :save_editable_groups
  end

  def in_editable_groups=(ids)
    @editable_group_ids = ids.uniq
  end

  def in_editable_groups
    @editable_group_ids ||=
      if editable_group
        editable_group.group_ids_as_array.tap { |ids| ids << 'ALL' if editable_group.all }
      else
        []
      end
  end

  private

  def save_editable_groups
    return true unless @editable_group_ids.kind_of?(Array)

    all = !!@editable_group_ids.delete('ALL')
    group_ids = @editable_group_ids.join(' ').strip
    @editable_group_ids = nil

    if editable_group
      editable_group.group_ids = group_ids
      editable_group.all = all
      editable_group.save
    else
      build_editable_group(group_ids: group_ids, all: all).save
    end
  end
end
