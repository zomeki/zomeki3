class Survey::Question < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Site
  include Cms::Model::Auth::Content

  default_scope { order(:sort_no, :id) }

  attribute :sort_no, :integer, default: 10

  enum_ish :state, [:public, :closed], default: :public
  enum_ish :form_type, [:text_field, :text_field_email, :text_area,
                        :select, :radio_button, :check_box, :free], default: :text_field
  enum_ish :required, [true, false], default: true

  belongs_to :form, required: true
  has_many :answers

  delegate :content, to: :form

  validates :state, presence: true
  validates :title, presence: true
  validates :sort_no, presence: true

  define_site_scope :form

  scope :public_state, -> { where(state: 'public') }

  def form_options_for_select
    form_options.gsub("\r\n", "\n").gsub("\r", "\n").split("\n")
  end

  def email_field?
    form_type == 'text_field_email'
  end
end
