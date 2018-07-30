class GpCalendar::Event < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Rel::Creator
  include Sys::Model::Rel::File
  include Cms::Model::Rel::Content
  include Cms::Model::Auth::Content
  include GpCategory::Model::Rel::Category

  ORDER_OPTIONS = [['作成日時（降順）', 'created_at_desc'], ['作成日時（昇順）', 'created_at_asc']]

  # Not saved to database
  attr_accessor :doc

  enum_ish :state, [:public, :closed], default: :public
  enum_ish :target, [:_self, :_blank], default: :_self

  # Content
  belongs_to :content, class_name: 'GpCalendar::Content::Event', required: true

  before_save :set_name
  before_destroy :close_files

  after_save     GpCalendar::Publisher::EventCallbacks.new, if: :changed?
  before_destroy GpCalendar::Publisher::EventCallbacks.new, prepend: true

  validates :state, presence: true
  validates :started_on, presence: true
  validates :ended_on, presence: true
  validates :title, presence: true
  validates :name, uniqueness: { scope: :content_id }, format: { with: /\A[\-\w]*\z/ }

  validate :dates_range

  scope :public_state, -> { where(state: 'public') }
  scope :scheduled_on, ->(date) { scheduled_between(date, date) }
  scope :scheduled_between, ->(start_date, end_date) {
    dates_intersects(:started_on, :ended_on, start_date.try(:beginning_of_day), end_date.try(:end_of_day))
  }

  def public_holidays
    return unless started_on
    content.public_holidays.scheduled_on(started_on)
   end

  def public_uri
    return unless node = content.node
    "#{node.public_uri}#{name}/"
  end

  def public_path
    return unless uri = public_uri
    "#{site.public_path}#{uri}"
  end

  def public_smart_phone_path
    return unless uri = public_uri
    "#{site.public_smart_phone_path}#{uri}"
  end

  def publish_files
    super
    publish_smart_phone_files if content.site.publish_for_smart_phone?
  end

  private

  def set_name
    return if self.name.present?
    date = (created_at || Time.now).strftime('%Y%m%d')
    seq = Util::Sequencer.next_id('gp_calendar_events', version: date, site_id: content.site_id)
    self.name = Util::String::CheckDigit.check(date + format('%04d', seq))
  end

  def dates_range
    return if self.started_on.blank? && self.ended_on.blank?
    self.started_on = self.ended_on if self.started_on.blank?
    self.ended_on = self.started_on if self.ended_on.blank?
    errors.add(:ended_on, "が#{self.class.human_attribute_name :started_on}を過ぎています。") if self.ended_on < self.started_on
  end

  class << self
    def from_doc(doc, calendar_content = nil)
      event = self.new(
        title: doc.title,
        target: '_self',
        started_on: doc.event_started_on,
        ended_on: doc.event_ended_on,
        description: doc.summary,
        content: calendar_content,
        will_sync: 'disabled'
      )
      event.categories = doc.event_categories
      event.files = doc.files
      event.doc = doc
      event.readonly!
      event
    end
  end
end
