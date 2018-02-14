class GpTemplate::Template < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Rel::Creator
  include Cms::Model::Site
  include Cms::Model::Rel::Content
  include Cms::Model::Auth::Content

  default_scope { order("#{self.table_name}.sort_no IS NULL, #{self.table_name}.sort_no") }

  attribute :sort_no, :integer, default: 10

  enum_ish :state, [:public, :closed], default: :public, predicate: true

  belongs_to :content, :foreign_key => :content_id, :class_name => 'GpTemplate::Content::Template'
  validates :content_id, presence: true

  validates :state, presence: true

  has_many :items, :dependent => :destroy

  validates :title, presence: true

  scope :public_state, -> { where(state: 'public') }

  def public_items
    items.public_state
  end

  def duplicate
    item = self.class.new(self.attributes.except('id', 'created_at', 'updated_at'))
    item.title = item.title.gsub(/^(【複製】)*/, "【複製】")

    return false unless item.save(validate: false)

    items.each do |i|
      dupe_item = GpTemplate::Item.new(i.attributes.except('id', 'created_at', 'updated_at'))
      dupe_item.template_id = item.id
      dupe_item.save(validate: false)
    end

    return item
  end
end
