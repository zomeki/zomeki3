class Sys::EditableGroup < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Site

  ALL_GROUP = 0

  belongs_to :editable, polymorphic: true
  belongs_to :group, class_name: 'Sys::Group'

  define_site_scope :editable

  def all_group?
    group_id == ALL_GROUP
  end
end
