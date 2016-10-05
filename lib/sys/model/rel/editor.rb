module Sys::Model::Rel::Editor
  extend ActiveSupport::Concern

  included do
    has_many :editors, -> { order(updated_at: :desc, created_at: :desc) },
      class_name: 'Sys::Editor', dependent: :destroy, as: :editable

    after_save :save_editor
  end

  def last_editor
    editors.first
  end

  def save_editor
    return if Core.user_group.blank? || Core.user.blank?
    editors.create(group_id: Core.user_group.id, user_id: Core.user.id)
  end
end
