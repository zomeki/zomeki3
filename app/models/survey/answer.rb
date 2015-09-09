class Survey::Answer < ActiveRecord::Base
  include Sys::Model::Base

  belongs_to :form_answer
  validates :form_answer_id, presence: true

  belongs_to :question
  validates :question_id, presence: true
end
