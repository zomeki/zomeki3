class Survey::Answer < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Site

  belongs_to :form_answer, required: true
  belongs_to :question, required: true

  define_site_scope :form_answer
end
