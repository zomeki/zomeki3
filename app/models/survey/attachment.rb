class Survey::Attachment < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Base::File
  include Sys::Model::Base::File::Db
  include Cms::Model::Site

  belongs_to :site, class_name: 'Cms::Site'
  belongs_to :answer

  define_site_scope :answer
end
