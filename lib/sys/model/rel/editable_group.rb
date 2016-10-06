module Sys::Model::Rel::EditableGroup
  extend ActiveSupport::Concern

  included do
    has_many :editable_groups, class_name: 'Sys::EditableGroup', dependent: :destroy, as: :editable
    accepts_nested_attributes_for :editable_groups
    before_save :prepare_editable_groups, if: -> { @save_editable_groups }
  end

  def editable_groups_attributes=(val)
    @save_editable_groups = true
    super
  end

  private

  def prepare_editable_groups
    editable_groups.each do |eg|
      eg.mark_for_destruction if eg.group_id.nil?
    end
  end
end
