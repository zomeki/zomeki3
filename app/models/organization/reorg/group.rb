class Organization::Reorg::Group < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Content
  include Cms::Model::Auth::Content

  default_scope { order(:sort_no, :sys_group_code) }

  column_attribute :sort_no, default: 10

  enum_ish :state, [:public, :closed], default: :public, predicate: true
  enum_ish :docs_order, ['',
                         'display_published_at DESC, published_at DESC',
                         'display_published_at ASC, published_at ASC',
                         'display_updated_at DESC, updated_at DESC',
                         'display_updated_at ASC, updated_at ASC'], default: ''
  enum_ish :sitemap_state, [:visible, :hidden], default: :visible, predicate: true

  # Page
  belongs_to :concept, class_name: 'Cms::Concept'
  belongs_to :layout, class_name: 'Cms::Layout'
  belongs_to :more_layout, class_name: 'Cms::Layout'

  # Content
  belongs_to :content, class_name: 'Organization::Content::Group', required: true

  def sys_group
    Sys::Reorg::Group.in_site(content.site).where(code: sys_group_code).first
  end

  def parent
    return nil if sys_group.nil? || sys_group.parent.nil?
    self.class.where(content_id: content_id, sys_group_code: sys_group.parent.code).first
  end

  def children
    self.class.where(content_id: content_id, sys_group_code: sys_group.children.in_site(content.site).select(:code))
  end

  def ancestors(groups=[])
    parent.ancestors(groups) if parent
    groups << self
  end

  concerning :Migration do
    included do
      enum_ish :change_state, [:create, :update, :delete]
    end

    def org_group
      Organization::Group.find_by(content: content, sys_group_code: sys_group_code)
    end

    def detect_change_state
      if org_group.blank?
        'create'
      else
        new_attrs = attributes.slice(*sys_group.class.column_names)
                              .except('id', 'created_at', 'updated_at')
                              .sort
        old_attrs = org_group.attributes
                             .except('id', 'created_at', 'updated_at')
                             .sort
        if new_attrs != old_attrs
          'update'
        else
          nil
        end
      end
    end
  end
end
