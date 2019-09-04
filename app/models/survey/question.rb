class Survey::Question < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Auth::Content

  default_scope { order(:sort_no, :id) }

  column_attribute :description, html: true
  column_attribute :sort_no, default: 10

  enum_ish :state, [:public, :closed], default: :public
  enum_ish :form_type, [:text_field, :text_field_email, :text_area,
                        :select, :radio_button, :check_box, :attachment, :free], default: :text_field
  enum_ish :required, [true, false], default: true

  belongs_to :form, required: true
  has_many :answers

  delegate :site, to: :form
  delegate :content, to: :form

  validates :state, presence: true
  validates :title, presence: true
  validates :sort_no, presence: true
  
  validate :validate_file_max_size

  nested_scope :in_site, through: :form

  scope :public_state, -> { where(state: 'public') }

  def form_options_for_select
    form_options.gsub("\r\n", "\n").gsub("\r", "\n").split("\n")
  end

  def email_field?
    form_type == 'text_field_email'
  end

  def form_file_extensions
    form_file_extension.to_s.split(',').map(&:strip).select(&:present?)
  end
  
  def validate_file_max_size
    if form_file_max_size.to_i > 10
      errors.add(:form_file_max_size, 'は10MB以下の値を入力してください。')
    end
  end
end
