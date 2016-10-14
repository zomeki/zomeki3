class Sys::Creator < ApplicationRecord
  include Sys::Model::Base

  belongs_to :creatable, polymorphic: true

  belongs_to :user, class_name: 'Sys::User', required: true
  belongs_to :group, class_name: 'Sys::Group', required: true

  before_save :set_user
  before_save :set_group

  private

  def set_user
    self.user_id ||= Core.user.try!(:id)
  end

  def set_group
    self.group_id ||= Core.user_group.try!(:id)
  end
end
