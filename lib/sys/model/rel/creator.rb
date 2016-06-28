module Sys::Model::Rel::Creator
  ATTRIBUTE_NAMES = [:group_id, :user_id]

  def self.included(mod)
    mod.belongs_to :creator, class_name: 'Sys::Creator', dependent: :destroy

    name = mod.table_name
    if (refs = Sys::Creator.has_many name.to_sym, class_name: mod.name).kind_of?(Hash)
      ref = refs.with_indifferent_access[name]
      fail %!Table "#{name}" must have column named "#{ref.foreign_key}".! unless ref.foreign_key.in?(mod.column_names)
    end

    mod.before_save :save_creator
  end

  def in_creator=(values)
    @creator_attributes ||= {}.with_indifferent_access
    return @creator_attributes unless values.kind_of?(Hash)

    values = values.with_indifferent_access
    ATTRIBUTE_NAMES.each {|n| @creator_attributes[n] = values[n].presence }
  end

  def in_creator
    @creator_attributes ||= {}.with_indifferent_access
  end

  def join_creator
    ActiveSupport::Deprecation.warn("Replace condition_builder with arel (#{caller[0..4].join("\n")})")
    return true if @joined_creator
    @joined_creator = true
    join :creator
  end

  private

  def save_creator
    return true if creator

    @creator_attributes ||= {}.with_indifferent_access
    create_creator!(group_id: @creator_attributes[:group_id].presence || Core.user_group.id,
                    user_id: @creator_attributes[:user_id].presence || Core.user.id)
  end
end
