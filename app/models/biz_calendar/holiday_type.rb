class BizCalendar::HolidayType < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Rel::Creator
  include Cms::Model::Auth::Content

  include StateText

  STATE_OPTIONS = [['表示', 'visible'], ['非表示', 'hidden']]

  # Content
  belongs_to :content, :foreign_key => :content_id, :class_name => 'BizCalendar::Content::Place'
  validates :content_id, presence: true

  validates :state, :name, :title, presence: true
  validate :name_validity
  
  after_initialize :set_defaults

  scope :visible, -> { where(state: 'visible') }
  scope :search_with_params, ->(params = {}) {
    rel = all
    params.each do |n, v|
      next if v.to_s == ''
      case n
      when 's_event_date'
        rel.where!(event_date: v)
      when 's_title'
        rel = rel.search_with_text(:title, v)
      end
    end
    rel
  }

  def state_visible?
    state == 'visible'
  end

  def name_validity
    errors.add(:name, :invalid) if self.name && self.name !~ /^[\-\w]*$/
    if (type = self.class.where(name: self.name, state: self.state, content_id: self.content.id).first)
      unless type.id == self.id
        errors.add(:name, :taken) unless state_visible?
      end
    end
  end

  def set_defaults
    self.state ||= STATE_OPTIONS.first.last if self.has_attribute?(:state)
  end
end
