class Survey::FormAnswer < ApplicationRecord
  include Sys::Model::Base

  apply_simple_captcha

  default_scope { order(created_at: :desc) }

  belongs_to :form
  validates :form_id, presence: true

  has_many :answers, -> { order(:id) }, dependent: :destroy

  validate :validate_base

  def question_answers=(qa)
    qa.each do |key, value|
      next unless question = form.questions.find_by(id: key)
      answers.build(question: question, content: value.kind_of?(Array) ? value.reject{|v| v.blank? }.join(',') : value)
    end
    qa
  end

  # Use before saving answers
  def detect_answer_by_question(question)
    answers.detect{|a| a.question_id == question.id }
  end

  def reply_to
    if q = form.automatic_reply_question
      answers.each {|a| return a.content if a.question_id == q.id }
    end
    nil
  end

  private

  def validate_base
    errors.keys.each{|k| errors.delete(k) unless [:base, :form_id].include?(k) }
    answers.each do |answer|
      next if answer.question.form_type == 'free'
      if ['text_field', 'text_area'].include?(answer.question.form_type)
        max = answer.question.form_text_max_length
        errors.add(:base, "#{answer.question.title}は#{max}文字以内で入力してください。") if max && max < answer.content.size
      end
      if [ 'text_field_email' ].include?(answer.question.form_type)
        errors.add(:base, "#{answer.question.title}を正しく入力してください。") if answer.content !~ /\A.+@.+\z/ && !answer.content.blank?
      end
      errors.add(:base, "#{answer.question.title}を入力してください。") if answer.question.required? && answer.content.blank?
    end
  end
end
