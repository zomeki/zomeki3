class BizCalendar::HolidayType < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Rel::Creator
  include Cms::Model::Site
  include Cms::Model::Rel::Content
  include Cms::Model::Auth::Content

  enum_ish :state, [:visible, :hidden], default: :visible, predicate: true

  # Content
  belongs_to :content, class_name: 'BizCalendar::Content::Place', required: true

  validates :state, :name, :title, presence: true
  validate :name_validity
  
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

  def name_validity
    errors.add(:name, :invalid) if self.name && self.name !~ /^[\-\w]*$/
    if (type = self.class.where(name: self.name, state: self.state, content_id: self.content.id).first)
      unless type.id == self.id
        errors.add(:name, :taken) unless state_visible?
      end
    end
  end
end
