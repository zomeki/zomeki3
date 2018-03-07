module Sys::Model::Base
  extend ActiveSupport::Concern
  include Sys::Model::Scope

  included do
    self.table_name = self.to_s.underscore.gsub('/', '_').downcase.pluralize
    validates_with IntegerValidator
  end
end
