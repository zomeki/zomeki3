class Sys::UsersHold < ApplicationRecord
  include Sys::Model::Base

  belongs_to :user
  belongs_to :holdable, polymorphic: true

  nested_scope :in_site, through: :user

  def group_and_user_name
    return '' unless user
    "#{user.group.try!(:name)}#{user.name}"
  end

  def formatted_updated_at
    format = updated_at.today? ? :short_ja : :default_ja
    I18n.l(updated_at, format: format)
  end
end
