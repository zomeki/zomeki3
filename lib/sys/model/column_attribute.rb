module Sys::Model::ColumnAttribute
  extend ActiveSupport::Concern

  included do
    class_attribute :column_attributes
    self.column_attributes = {}
  end

  class_methods do
    def column_attribute(name, options)
      self.column_attributes[name] = options
    end

    def html_columns
      self.columns.select { |c| self.column_attributes.dig(c.name.to_sym, :html) }
    end

    def fts_columns
      self.columns.select { |c| self.column_attributes.dig(c.name.to_sym, :fts) }
    end

    private

    def load_schema!
      ret = super
      column_attributes.each do |name, options|
        name = name.to_s
        attribute_options = options.slice(:default)
        define_attribute(name, connection.lookup_cast_type_from_column(columns_hash[name]), attribute_options)
      end
      ret
    end
  end
end
