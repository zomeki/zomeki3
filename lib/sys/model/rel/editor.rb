module Sys::Model::Rel::Editor
  def self.included(mod)
    mod.has_many :editors, -> { order('updated_at DESC, created_at DESC') },
      class_name: 'Sys::Editor', dependent: :destroy, as: :editable

    mod.after_save :save_editor
  end

  def last_editor
    editors.first
  end

  def save_editor
    return false if Core.user_group.blank? || Core.user.blank?
    !!editors.create(group_id: Core.user_group.id, user_id: Core.user.id)
  end
end
