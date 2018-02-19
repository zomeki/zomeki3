class Survey::FormAnswer < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Site

  apply_simple_captcha

  default_scope { order(created_at: :desc) }

  belongs_to :form, required: true

  has_many :answers, -> { order(:id) }, dependent: :destroy

  validate :validate_answers

  define_site_scope :form

  def question_answers=(qa)
    qa.each do |key, value|
      next unless question = form.questions.find_by(id: key)
      answers.build(form_answer: self,
                    question: question,
                    content: value.kind_of?(Array) ? value.reject{|v| v.blank? }.join(',') : value)
    end
    qa
  end

  def reply_to
    if q = form.automatic_reply_question
      answers.each {|a| return a.content if a.question_id == q.id }
    end
    nil
  end

  def answered_full_uri
    uri = Addressable::URI.parse(answered_url)
    return answered_url unless uri

    if uri.absolute?
      answered_url
    elsif uri.path =~ %r{^/_ssl} && form.site.full_ssl_uri.present?
      Addressable::URI.join(form.site.full_ssl_uri, answered_url).to_s
    else
      Addressable::URI.join(form.site.full_uri, answered_url).to_s
    end
  end

  private

  def validate_answers
    errors.keys.each{|k| errors.delete(k) unless [:base, :form_id].include?(k) }
    answers.each do |answer|
      next if answer.question.form_type == 'free'
      if answer.invalid?
        answer.errors.full_messages.each { |msg| errors.add(:base, msg) } 
      end
    end
  end
end
