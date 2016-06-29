module Sys::Model::Rel::EditableGroup
  def self.included(mod)
    mod.has_one :editable_group, class_name: 'Sys::EditableGroup', dependent: :destroy, as: :editable
    mod.after_save :save_editable_groups
  end

  # setter always returns supplied argument
  def in_editable_groups=(ids)
    @editable_group_ids = (case ids
                           when Array
                             ids
                           when Hash
                             ids.values
                           else
                             ids.to_s.split
                           end).uniq
  end

  def in_editable_groups
    @editable_group_ids ||= if (eg = editable_group)
                              eg.group_ids.to_s.split.uniq
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
      eg = build_editable_group(group_ids: group_ids, all: all)
      eg.save
    end
  end
end
