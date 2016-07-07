module Sys::Model::Rel::Creator
  ATTRIBUTE_NAMES = [:group_id, :user_id]

  def self.included(mod)
    mod.has_one :creator, class_name: 'Sys::Creator', dependent: :destroy, as: :creatable
    mod.after_save :save_creator
  end

  # setter always returns supplied argument
  def in_creator=(values)
    values = (values.kind_of?(Hash) ? values : {}).with_indifferent_access
    ATTRIBUTE_NAMES.each {|n| creator_attributes[n] = values[n].presence }
  end

  def in_creator
    creator_attributes
  end

  def join_creator
    ActiveSupport::Deprecation.warn("Replace condition_builder with arel (#{caller[0..4].join("\n")})")
    return true if @joined_creator
    @joined_creator = true
    join :creator
  end

  private

  def creator_attributes
    return @creator_attributes if @creator_attributes
    @creator_attributes = {}.with_indifferent_access.tap do |attrs|
      next unless creator
      ATTRIBUTE_NAMES.each {|n| attrs[n] = creator[n].presence }
    end
  end

  def save_creator
    return true if creator
    c = build_creator(group_id: creator_attributes[:group_id].presence || Core.user_group.try!(:id),
                      user_id: creator_attributes[:user_id].presence || Core.user.try!(:id))
    c.save
  end
end
