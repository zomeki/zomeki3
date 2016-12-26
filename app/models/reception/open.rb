class Reception::Open < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Rel::Creator
  include Sys::Model::Rel::Task
  include Cms::Model::Auth::Content

  include StateText
  include Cms::Base::PublishQueue::Content

  STATE_OPTIONS = [['下書き','draft'],['公開','public']]

  belongs_to :course
  has_many :applicants
  has_many :received_applicants, -> { where(state: 'received') }, class_name: 'Reception::Applicant'

  after_save :save_tasks

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
    sql = Reception::Applicant.select('count("reception_applicants"."id")')
                              .where(state: 'received')
                              .where("reception_applicants.open_id = reception_opens.id").to_sql
    where(%Q|"reception_courses"."capacity" IS NULL OR "reception_courses"."capacity" > (#{sql})|)
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

  def state_draft?
    state == 'draft'
  end

  def state_public?
    state == 'public'
  end

  def available_period?(time = Time.now)
    expired_at.nil? || time <= expired_at
  end

  def within_capacity?
    course.capacity.nil? || received_applicants.count < course.capacity
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
    # to publish piece
    self.updated_at = Time.now
    save
  end

  private

  def save_tasks
    return if !state_public? || !expired_at

    task = tasks.where(name: 'expire').first_or_initialize
    task.process_at = expired_at
    task.save
  end
end
