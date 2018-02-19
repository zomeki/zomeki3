class Survey::Answer < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Site

  belongs_to :form_answer, required: true
  belongs_to :question, required: true

  with_options unless: -> { question.blank? } do
    validate :validate_required
    validate :validate_text_length, if: -> { question.form_type.in?(%w(text_field text_area)) }
    validate :validate_block_word, if: -> { question.form_type.in?(%w(text_field text_area)) }
    validate :validate_email_format, if: -> { question.form_type == 'text_field_email' }
  end

  define_site_scope :form_answer

  private

  def validate_required
    if question.required? && content.blank?
      errors.add(:base, "#{question.title}を入力してください。")
    end 
  end

  def validate_text_length
    max = question.form_text_max_length
    if max && max < content.size
      errors.add(:base, "#{question.title}は#{max}文字以内で入力してください。")
    end
  end

  def validate_block_word
    question.content.block_words.each do |word|
      if content.include?(word)
        errors.add :base, "#{question.title}に禁止語句（#{word}）が含まれています。"
      end
    end
  end

  def validate_email_format
    if content !~ /\A.+@.+\z/
      errors.add(:base, "#{question.title}を正しく入力してください。")
    end
  end
end
