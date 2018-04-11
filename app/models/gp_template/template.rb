class GpTemplate::Template < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Content
  include Cms::Model::Auth::Content

  default_scope { order(:sort_no, :id) }

  column_attribute :sort_no, default: 10

  enum_ish :state, [:public, :closed], default: :public, predicate: true

  belongs_to :content, class_name: 'GpTemplate::Content::Template', required: true

  has_many :items, dependent: :destroy

  validates :state, presence: true
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
