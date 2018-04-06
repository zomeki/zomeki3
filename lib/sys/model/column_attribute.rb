module Sys::Model::ColumnAttribute
  extend ActiveSupport::Concern

  included do
    class_attribute :column_attributes
  end

  class_methods do
    def column_attribute(name, options)
      self.column_attributes ||= {}
      self.column_attributes[name] = options
    end

    private

    def load_schema!
      ret = super
      column_attributes.to_h.each do |name, options|
        name = name.to_s
        define_attribute(name, connection.lookup_cast_type_from_column(columns_hash[name]), options)
      end
      ret
    end
  end
end
