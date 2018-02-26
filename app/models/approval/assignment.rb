class Approval::Assignment < ApplicationRecord
  include Sys::Model::Base

  enum_ish :assign_type, [:user, :group_users], default: :user

  belongs_to :assignable, polymorphic: true
  belongs_to :user, class_name: 'Sys::User'
  belongs_to :group, class_name: 'Sys::Group'

  nested_scope :in_site, through: :assignable

  def assign_type_group_users?
    assign_type == 'group_users'
  end

  def assigner_label
    case assign_type
    when 'group_users'
      group_id == 0 ? "*自所属ユーザー" : "*#{group.try(:name)}所属ユーザー"
    else
      user.try(:name)
    end
  end

  def assigner_id
    case assign_type
    when 'group_users'
      "gu#{group_id}"
    else
      user_id
    end
  end

  def assigners(requester)
    case assign_type
    when 'group_users'
      if group_id == 0 && requester && (requester_group = requester.groups.first)
        requester_group.users.where(state: 'enabled') - [requester]
      elsif group
        group.users.where(state: 'enabled') - [requester]
      else
        []
      end
    else
      [user].compact
    end
  end
end
