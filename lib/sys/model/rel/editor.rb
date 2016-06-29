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
    e = editors.build(group_id: Core.user_group.try!(:id), user_id: Core.user.try!(:id))
    e.save
  end
end
