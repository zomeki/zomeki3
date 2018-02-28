module Sys::Model::Slave
  extend ActiveSupport::Concern
  include Sys::Model::Scope

  included do
    self.table_name = self.to_s.underscore.sub('/slave/', '/').gsub('/', '_').downcase.pluralize
  end
end
