module Sys::Model::Rel::Creator
  ATTRIBUTE_NAMES = [:group_id, :user_id]

  def self.included(mod)
    mod.has_one :creator, class_name: 'Sys::Creator', dependent: :destroy, as: :creatable
    mod.after_save :save_creator
  end

  def in_creator=(value)
    @in_creator = value.with_indifferent_access
  end

  def in_creator
    if @in_creator
      @in_creator
    elsif creator
      creator.attributes.slice('group_id', 'user_id').with_indifferent_access
    else
      {}.with_indifferent_access
    end
  end

  private

  def save_creator
    build_creator unless creator

    if @in_creator
      creator.group_id = @in_creator['group_id']
      creator.user_id = @in_creator['user_id']
    end
    creator.group_id ||= Core.user_group.try!(:id)
    creator.user_id ||= Core.user.try!(:id)
    creator.save
  end
end
