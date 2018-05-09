module Sys::Model::Scope
  extend ActiveSupport::Concern

  included do
    scope :select_without, ->(*columns) {
      select(column_names - Array(columns).map(&:to_s))
    }
    scope :search_with_text, ->(*args) {
      words = args.pop.to_s.split(/[ 　]+/)
      columns = args.flatten
      where(words.map{|w| columns.map{|c| arel_table[c].matches("%#{escape_like(w)}%") }.reduce(:or) }.reduce(:and))
    }
    scope :search_with_logical_query, ->(*args) {
      if (tree = LogicalQueryParser.new.parse(args.last.to_s))
        args.pop
        where(tree.to_sql(model: self, columns: args))
      else
        search_with_text(*args)
      end
    }
    scope :ci_match, ->(column_text) {
      column_text.inject(all) do |rel, (column, text)|
        column = connection.quote_table_name("#{table_name}.#{column}")
        if text.is_a?(Array)
          if text.empty?
            rel.none!
          else
            cond = text.map { |t| "LOWER(#{connection.quote(t)})" }.join(', ')
            rel.where!("LOWER(#{column}) IN (#{cond})")
          end
        else
          rel.where!("LOWER(#{column}) = LOWER(#{connection.quote(text)})")
        end
      end
    }

    scope :date_before, ->(column, date) {
      where(arel_table[column].lteq(date))
    }
    scope :date_after, ->(column, date) {
      where(arel_table[column].gteq(date))
    }
    scope :date_between, ->(column, date1, date2) {
      where(arel_table[column].in(date1..date2))
    }
    scope :dates_intersects, ->(start_column, end_column, start_date, end_date) {
      rel = all
      rel.where!(arel_table[end_column].gteq(start_date)) if start_date
      rel.where!(arel_table[start_column].lteq(end_date)) if end_date
      rel
    }
  end

  module ClassMethods
    def escape_like(s)
      s.gsub(/[\\%_]/) {|r| "\\#{r}"}
    end

    def replace_for_all(column, from, to)
      column = connection.quote_column_name(column)
      update_all(["#{column} = REPLACE(#{column}, ?, ?)", from, to])
    end

    def concat_text_for_all(column, text)
      column = connection.quote_column_name(column)
      update_all(["#{column} = CONCAT(#{column}, ?)", text])
    end
  end
end
