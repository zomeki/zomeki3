class Survey::Answer < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Site

  belongs_to :form_answer
  validates :form_answer_id, presence: true

  belongs_to :question
  validates :question_id, presence: true

  define_site_scope :form_answer
end
