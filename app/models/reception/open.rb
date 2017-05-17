class Reception::Open < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Rel::Creator
  include Sys::Model::Rel::Task
  include Cms::Model::Auth::Content

  include StateText

  STATE_OPTIONS = [['下書き','draft'],['公開','public']]

  belongs_to :course
  has_many :applicants, dependent: :destroy

  before_save :prepare_expire_task

  after_save     Cms::Publisher::ContentRelatedCallbacks.new, if: :changed?
  before_destroy Cms::Publisher::ContentRelatedCallbacks.new

  validates :title, presence: true
  validates :open_on, presence: true
  validates :start_at, presence: true
  validates :end_at, presence: true

  scope :public_state, -> { where(state: 'public' ) }
  scope :order_by_open_at, -> { order(:open_on, :start_at, :end_at) }
  scope :available_period, ->(time = Time.now) {
    where([
      arel_table[:expired_at].eq(nil),
      arel_table[:expired_at].gt(time)
    ].reduce(:or))
  }
  scope :within_capacity, -> {
    courses = Reception::Course.arel_table
    joins(:course).where([
      courses[:capacity].eq(nil),
      courses[:capacity].gt(arel_table[:received_applicants_count]),
    ].reduce(:or))
  }

  def content
    course.content
  end

  def open_at_text
    if open_on && start_at && end_at
      "#{I18n.l(open_on, format: :long_ja)} #{start_at.strftime('%H:%M')} ～  #{end_at.strftime('%H:%M')}"
    elsif open_on && start_at
      "#{I18n.l(open_on, format: :long_ja)} #{start_at.strftime('%H:%M')}"
    else open_on
      I18n.l(open_on)
    end
  end

  def open_on_start_at
    d = open_on.to_datetime
    d += start_at.seconds_since_midnight.seconds if start_at
    d
  end

  def state_draft?
    state == 'draft'
  end

  def state_public?
    state == 'public'
  end

  def state_closed?
    state == 'closed'
  end

  def available_period?(time = Time.now)
    expired_at.nil? || time <= expired_at
  end

  def within_capacity?
    course.capacity.nil? || received_applicants_count < course.capacity
  end

  def applicable?
    state_public? && available_period? && within_capacity? && course.state_public?
  end

  def link_state_text
    if applicable?
      '申込む'
    elsif !within_capacity?
      '満員'
    elsif !available_period?
      '申込終了'
    else
      '申込停止'
    end
  end

  def expire
    Cms::Publisher::ContentRelatedCallbacks.new.enqueue(self)
  end

  def update_received_applicants_count
    update_column(:received_applicants_count, applicants.where(state: 'received').count)
  end

  private

  def prepare_expire_task
    return if !state_public? || !expired_at

    task = Sys::Task.where(processable: self, name: 'expire').first_or_initialize
    task.state = 'queued'
    task.site_id = content.site_id
    task.process_at = expired_at
    self.tasks_attributes = task.attributes
  end
end
