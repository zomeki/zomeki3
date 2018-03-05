class Sys::UsersSession < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Auth::Manager

  belongs_to :user
  has_many :users_holds, primary_key: :session_id, foreign_key: :session_id, dependent: :delete_all

  nested_scope :in_site, through: :user

  class << self
    def cleanup
      self.date_before(:updated_at, Rails.application.config.session_options[:expire_after].ago).delete_all
    end
  end
end
