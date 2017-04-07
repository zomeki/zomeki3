class Approval::Assignment < ApplicationRecord
  include Sys::Model::Base

  belongs_to :assignable, polymorphic: true
  belongs_to :user, class_name: 'Sys::User'
  belongs_to :group, class_name: 'Sys::Group'

  after_initialize :set_defaults

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

  def assigners
    case assign_type
    when 'group_users'
      if group_id == 0
        Core.user_group.users.where(state: 'enabled')
      elsif group
        group.users.where(state: 'enabled')
      else
        []
      end
    else
      [user].compact
    end
  end

  private

  def set_defaults
    self.assign_type ||= 'user' if self.has_attribute?(:assign_type)
  end
end
