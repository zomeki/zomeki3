class Reception::Applicant < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Rel::Creator
  include Cms::Model::Auth::Content

  STATE_OPTIONS = [['申込','applied'],['受付','received'],['キャンセル','canceled']]
  APPLIED_FROM_OPTIONS = [['フォーム','public'],['登録','admin']]

  attr_accessor :email_confirmation
  has_secure_token :token

  belongs_to :open

  before_save :set_applied_at
  before_save :set_seq_no

  validates :name, presence: true
  validates :kana, presence: true
  validates :tel, presence: true
  validates :email, presence: true, confirmation: true
  validate :validate_capacity, on: :public_applicant

  scope :received_state, -> { where(state: 'received') }
  scope :canceled_state, -> { where(state: 'canceled') }
  scope :search_with_criteria, ->(criteria) {
    criteria ||= {}
    rel = all
    [:state].each do |key|
      rel = rel.where(key => criteria[key]) if criteria[key].present?
    end
    rel
  }

  def content
    course.content
  end

  def course
    open.course
  end

  def state_text
    STATE_OPTIONS.rassoc(state).try(:first)
  end

  def applied_from_text
    APPLIED_FROM_OPTIONS.rassoc(applied_from).try(:first)
  end

  def cancelable?
    state == 'received' && open.state_public? && open.available_period?
  end

  private

  def validate_capacity
    if open && !open.within_capacity?
      errors.add(:base, 'ご指定の参加日は定員を超過したためお申込できません。')
    end
  end

  def set_applied_at
    self.applied_at ||= Time.now
  end

  def set_seq_no
    self.seq_no ||= Util::Sequencer.next_id('reception_applicants', version: course.content_id) if state == 'received'
  end
end
