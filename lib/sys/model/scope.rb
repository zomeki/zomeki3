module Sys::Model::Scope
  extend ActiveSupport::Concern

  included do
    scope :search_with_text, ->(*args) {
      words = args.pop.to_s.split(/[ 　]+/)
      columns = args
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
  end

  module ClassMethods
    def escape_like(s)
      s.gsub(/[\\%_]/) {|r| "\\#{r}"}
    end

    def union(relations)
      sql = '((' + relations.map{|rel| rel.to_sql}.join(') UNION (') + ')) AS ' + self.table_name 
      from(sql)
    end

    def replace_for_all(column, from, to)
      column = connection.quote_column_name(column)
      update_all(["#{column} = REPLACE(#{column}, ?, ?)", from, to])
    end
  end
end
