class Survey::Attachment < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Base::File
  include Sys::Model::Base::File::Db

  belongs_to :site, class_name: 'Cms::Site'
  belongs_to :answer

  nested_scope :in_site, through: :answer
end
