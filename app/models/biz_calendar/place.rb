class BizCalendar::Place < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Rel::Creator
  include Cms::Model::Auth::Content

  include StateText

  STATE_OPTIONS = [['公開', 'public'], ['非公開', 'closed']]
  BUSINESS_HOURS_STATE_OPTIONS = [['表示する','visible'],['表示しない','hidden']]
  BUSINESS_HOLIDAY_STATE_OPTIONS = [['表示する','visible'],['表示しない','hidden']]

  # Content
  belongs_to :content, :foreign_key => :content_id, :class_name => 'BizCalendar::Content::Place'
  validates :content_id, presence: true

  has_many :hours,              :class_name => 'BizCalendar::BussinessHour',    :dependent => :destroy
  has_many :holidays,           :class_name => 'BizCalendar::BussinessHoliday', :dependent => :destroy
  has_many :exception_holidays, :class_name => 'BizCalendar::ExceptionHoliday', :dependent => :destroy

  validates :state, :url, :title, presence: true
  validate :url_validity

  after_initialize :set_defaults

  after_save     Cms::Publisher::ContentCallbacks.new, if: :changed?
  before_destroy Cms::Publisher::ContentCallbacks.new

  scope :public_state, -> { where(state: 'public') }
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

  def get_bussines_time(date=Date.today)
    hour = BizCalendar::BussinessHour.arel_table

    where1 = hour[:fixed_start_date].lteq(date).and(hour[:fixed_end_date].gteq(date)).and(hour[:repeat_type].eq('').or(hour[:repeat_type].eq(nil)))

    where2 = hour[:repeat_type].not_eq('').and(hour[:repeat_type].not_eq(nil))
              .and(hour[:start_date].lteq(date))

    end_type_rel = hour.grouping(hour[:end_type].eq(2).and(hour[:end_date].gteq(date)))
    end_type_rel = end_type_rel.or(hour[:end_type].eq(0))
    end_type_rel = end_type_rel.or(hour[:end_type].eq(1))

    where2 = where2.and(end_type_rel)

    _hours =  hours.public_state.where(hour.grouping(where1).or(hour.grouping(where2))).all

    date_hours = []
    _hours.each do |h|
      date_hours << h if h.repeat_type.blank? || (!h.repeat_type.blank? && h.check(date))
    end
    return date_hours
  end

  def state_public?
    state == 'public'
  end

  def public_uri
    return '' unless node = content.public_node
    "#{node.public_uri}#{url}/"
  end

  def public_path
    return '' unless node = content.public_node
    "#{node.public_path}#{url}/"
  end

  def public_smart_phone_path
    return '' unless node = content.public_node
    "#{node.public_smart_phone_path}#{url}/"
  end

  def next_holiday(sdate=Date.today)
    return '' if holidays.public_state.blank?
    next_holiday = nil

    self.holidays.public_state.each do |h|
      if h.repeat_type.blank?
        next if h.holiday_end_date < sdate
      elsif !h.repeat_type.blank? && h.end_type == 2
        next if !h.end_date.blank? && h.end_date < sdate
      end

      h.get_repeat_dates(sdate).each do |d|
        next if d < sdate
        next_holiday = d if next_holiday.blank? || next_holiday > d
      end
    end

    return next_holiday
  end

  def bread_crumbs(node)
    crumbs = []
    node.routes.each do |r|
      c = []
      r.each {|i| c << [i.title, i.public_uri] }

      uri = c.last[1] || '/'
      c << [title, "#{uri}#{url}/"]

      crumbs << c
    end
    Cms::Lib::BreadCrumbs.new(crumbs)
  end

  def url_validity
    errors.add(:url, :invalid) if self.url && self.url !~ /^[\-\w]*$/
    if (doc = self.class.where(url: self.url, state: self.state, content_id: self.content.id).first)
      unless doc.id == self.id
        errors.add(:url, :taken) unless state_public?
      end
    end
  end

  def set_defaults
    self.state                  ||= STATE_OPTIONS.first.last if self.has_attribute?(:state)
    self.business_hours_state   ||= BUSINESS_HOURS_STATE_OPTIONS.last.last if self.has_attribute?(:business_hours_state)
    self.business_holiday_state ||= BUSINESS_HOLIDAY_STATE_OPTIONS.last.last if self.has_attribute?(:business_holiday_state)
    self.sort_no                ||= 10 if self.has_attribute?(:sort_no)
  end
end
