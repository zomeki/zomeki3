class Mailin::Filter < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Rel::Creator
  include Cms::Model::Site
  include Cms::Model::Rel::Content
  include Cms::Model::Auth::Content

  enum_ish :state, [:enabled, :disabled], default: :enabled
  enum_ish :logic, [:and, :or], default: :and

  belongs_to :content, foreign_key: :content_id, class_name: 'Mailin::Content::Filter'
  belongs_to :dest_content, foreign_key: :dest_content_id, class_name: 'GpArticle::Content::Doc'
  belongs_to :default_user, foreign_key: :default_user_id, class_name: 'Sys::User'

  validates :content_id, presence: true
  validates :dest_content_id, presence: true

  def match?(mail)
    addrs = []
    addrs += mail.to if mail.to
    addrs += mail.cc if mail.cc && include_cc?

    fields = [[to, addrs.join(', ')], [subject, mail.subject.to_s]]

    case logic
    when 'and'
      fields.all? do |pattern, mail_value|
        ::File.fnmatch?("*#{pattern}*", mail_value)
      end
    when 'or'
      fields.any? do |pattern, mail_value|
        ::File.fnmatch?("*#{pattern}*", mail_value)
      end
    else
      false
    end
  end
end
