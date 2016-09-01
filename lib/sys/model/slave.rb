module Sys::Model::Slave
  extend ActiveSupport::Concern

  included do
    self.table_name = self.to_s.underscore.sub('/slave/', '/').gsub('/', '_').downcase.pluralize
  end
end
