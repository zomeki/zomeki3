class GpTemplate::Template < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Rel::Creator
  include Cms::Model::Site
  include Cms::Model::Rel::Content
  include Cms::Model::Auth::Content

  include StateText

  STATE_OPTIONS = [['公開', 'public'], ['非公開', 'closed']]

  default_scope { order(:sort_no, :id) }

  belongs_to :content, class_name: 'GpTemplate::Content::Template', required: true

  has_many :items, dependent: :destroy

  validates :state, presence: true
  validates :title, presence: true

  after_initialize :set_defaults

  scope :public_state, -> { where(state: 'public') }

  def public_items
    items.public_state
  end

  def state_public?
    state == 'public'
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

  private

  def set_defaults
    self.state   = STATE_OPTIONS.first.last if self.has_attribute?(:state) && self.state.nil?
    self.sort_no = 10 if self.has_attribute?(:sort_no) && self.sort_no.nil?
  end
end
