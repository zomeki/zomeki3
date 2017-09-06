class Mailin::Filter < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Rel::Creator
  include Cms::Model::Site
  include Cms::Model::Rel::Content
  include Cms::Model::Auth::Content

  include StateText

  STATE_OPTIONS = [['有効','enabled'],['無効','disabled']]

  belongs_to :content, foreign_key: :content_id, class_name: 'Mailin::Content::Filter'
  belongs_to :dest_content, foreign_key: :dest_content_id, class_name: 'GpArticle::Content::Doc'
  belongs_to :default_user, foreign_key: :default_user_id, class_name: 'Sys::User'

  validates :content_id, presence: true
  validates :dest_content_id, presence: true

  def match?(mail)
    [[to, mail.to.first], [subject, mail.subject]].all? do |pattern, mail_value|
      ::File.fnmatch?("*#{pattern}*", mail_value.to_s)
    end
  end
end
