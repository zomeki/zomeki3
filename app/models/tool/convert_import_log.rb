class Tool::ConvertImportLog < ActiveRecord::Base
  include Sys::Model::Base

  belongs_to :import, class_name: 'Tool::ConvertImport'

  default_scope { order(:id) }
end
