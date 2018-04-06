class Cms::LinkCheckLog < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Rel::Site

  column_attribute :checked, default: false

  enum_ish :result_state, [:success, :failure, :skip]

  belongs_to :link_checkable, polymorphic: true

  scope :search_with_params, ->(criteria) {
    rel = all
    rel = rel.search_with_text(:title, :body, :url, :reason, criteria[:keyword]) if criteria[:keyword].present?
    rel = rel.where(result_state: criteria[:result_state]) if criteria[:result_state].present?
    rel = rel.with_creator_group(criteria[:group_id]) if criteria[:group_id].present?
    rel
  }
  scope :with_creator_group, ->(group) {
    rels = self.group(:link_checkable_type).pluck(:link_checkable_type).map do |type|
             model = type.safe_constantize
             next unless model
             creatable_ids = Sys::Creator.select(:creatable_id).where(creatable_type: type, group_id: group) 
             where(link_checkable_type: type, link_checkable_id: model.where(id: creatable_ids))
           end
    rels.compact.reduce(:union)
  }
end
