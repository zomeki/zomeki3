class Sys::Creator < ApplicationRecord
  include Sys::Model::Base

  belongs_to :creatable, polymorphic: true

  belongs_to :user, required: true
  belongs_to :group, required: true

  before_save :set_user
  before_save :set_group

  nested_scope :in_site, through: :creatable

  private

  def set_user
    self.user_id ||= Core.user.try!(:id)
  end

  def set_group
    self.group_id ||= Core.user_group.try!(:id)
  end
end
