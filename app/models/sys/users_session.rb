class Sys::UsersSession < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Auth::Manager

  belongs_to :user

  nested_scope :in_site, through: :user

  class << self
    def cleanup
      self.date_before(:updated_at, Rails.application.config.session_options[:expire_after].ago).delete_all
    end
  end
end
