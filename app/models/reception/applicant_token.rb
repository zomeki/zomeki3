class Reception::ApplicantToken < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Site

  belongs_to :open
  belongs_to :applicant

  define_site_scope :open

  def cancelable?
    state == 'received' && open.state_public? && open.available_period?
  end
end
