class GpCalendar::Holiday < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Content
  include Cms::Model::Auth::Content

  enum_ish :state, [:public, :closed], default: :public

  # Content
  belongs_to :content, class_name: 'GpCalendar::Content::Event', required: true

  after_save     Cms::Publisher::ContentCallbacks.new(belonged: true), if: :changed?
  before_destroy Cms::Publisher::ContentCallbacks.new(belonged: true), prepend: true

  validates :state, presence: true
  validates :title, presence: true

  scope :public_state, -> { where(state: 'public') }
  scope :scheduled_on, ->(date) { scheduled_between(date, date) }
  scope :scheduled_between, ->(start_date, end_date) {
    if start_date && end_date
      unrepeated = where("repeat = false AND TO_CHAR(date, 'YYYYMMDD') >= ? AND TO_CHAR(date, 'YYYYMMDD') <= ?", start_date.strftime('%Y%m%d'), end_date.strftime('%Y%m%d'))
      repeated = if start_date.year == end_date.year
                   where("repeat = true AND TO_CHAR(date, 'MMDD') >= ? AND TO_CHAR(date, 'MMDD') <= ?", start_date.strftime('%m%d'), end_date.strftime('%m%d'))
                 else
                   where("repeat = true AND TO_CHAR(date, 'MMDD') >= ? OR TO_CHAR(date, 'MMDD') <= ?", start_date.strftime('%m%d'), end_date.strftime('%m%d'))
                 end
      [unrepeated, repeated].reduce(:or)
    else
      none
    end
  }

  def match?(target_date)
    [date.month, date.day] == [target_date.month, target_date.day]
  end
end
