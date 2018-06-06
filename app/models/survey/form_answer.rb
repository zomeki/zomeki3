class Survey::FormAnswer < ApplicationRecord
  include Sys::Model::Base

  apply_simple_captcha

  default_scope { order(created_at: :desc) }

  belongs_to :form, required: true

  has_many :answers, -> { order(:id) }, dependent: :destroy

  validate :validate_answers

  nested_scope :in_site, through: :form

  def question_answers=(qa)
    qa.each do |key, value|
      next unless question = form.questions.detect { |q| q.id == key.to_i }
      case question.form_type
      when 'attachment'
        if (file = value[:file]) && file.respond_to?(:original_filename)  # UploadedFile
          answer = answers.build(form_answer: self, question: question, content: file.original_filename)
          at = answer.build_attachment(site_id: form.content.site_id)
          at.name = at.title = file.original_filename
          at.file = file
          at.data = file.read
        elsif value[:name]
          answer = answers.build(form_answer: self, question: question, content: value[:name])
          if value[:data].present?
            at = answer.build_attachment(site_id: form.content.site_id)
            at.name = Util::File.sanitize_filename(value[:name])
            at.title = value[:name]
            at.file = Sys::Lib::File::NoUploadedFile.new(data: Base64.strict_decode64(value[:data]), filename: at.name)
          end
        end
      else
        answers.build(form_answer: self,
                      question: question,
                      content: value.kind_of?(Array) ? value.select(&:present?).join(',') : value)
      end
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
