module Sys::Model::Rel::Creator
  extend ActiveSupport::Concern

  included do
    has_one :creator, class_name: 'Sys::Creator', dependent: :destroy, as: :creatable
    accepts_nested_attributes_for :creator
    before_save :prepare_creator
  end

  private

  def prepare_creator
    return if Core.user_group.blank? || Core.user.blank?

    unless creator
      build_creator(
        group_id: Core.user_group.id,
        user_id: Core.user.id
      )
    end
  end
end
