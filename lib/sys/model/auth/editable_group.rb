module Sys::Model::Auth::EditableGroup
  extend ActiveSupport::Concern

  included do
    scope :editable, -> {
      if Core.user.has_auth?(:manager)
        all
      else
        creators = Sys::Creator.arel_table
        editable_groups = Sys::EditableGroup.arel_table
        gid = Core.user_group.id
        distinct.joins(:editable_group, :creator).where([
          creators[:group_id].eq(Core.user_group.id),
          Arel.sql("sys_editable_groups.group_ids ~ '(^| )#{gid}( |$)'"),
        ].reduce(:or))
      end
    }
  end

  def creatable?
    return false unless Core.user.has_auth?(:creator)
    #return Core.user.has_priv?(:create, :item => content.concept)
    return true
  end

  def editable?
    return true if Core.user.has_auth?(:manager)
    return false unless creator
    return true if creator.group_id == Core.user_group.id
    return false unless editable_group
    return editable_group.group_ids =~ /(^| )#{Core.user_group.id}( |$)/
  end

  def deletable?
    editable?
  end
end
