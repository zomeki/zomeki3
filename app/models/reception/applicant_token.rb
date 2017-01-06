class Reception::ApplicantToken < ApplicationRecord
  include Sys::Model::Base

  belongs_to :open
  belongs_to :applicant

  def cancelable?
    state == 'received' && open.state_public? && open.available_period?
  end
end
