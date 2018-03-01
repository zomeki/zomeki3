module Sys::Model::Validation
  extend ActiveSupport::Concern

  included do
    validate do
      integer_columns = self.class.columns.select { |c| c.type == :integer }
      integer_columns.each do |column|
        if (value = self[column.name])
          max = 1 << ((column.limit || 4) * 8 - 1)
          min = -max
          if value <= min
            errors.add(column.name, :greater_than, count: min)
          end
          if value >= max
            errors.add(column.name, :less_than, count: max)
          end
        end
      end
    end
  end
end
