module Sys::Model::Base
  extend ActiveSupport::Concern
  include Sys::Model::Scope
  include Sys::Model::Preload
  include Sys::Model::ConditionBuilder

  included do
    self.table_name = self.to_s.underscore.gsub('/', '_').downcase.pluralize
  end

  def locale(name)
    label = I18n.t name, :scope => [:activerecord, :attributes, self.class.to_s.underscore]
    return label =~ /^translation missing:/ ? name.to_s.humanize : label
  end

  def expand_join_query(joins)
    join_dependency = ActiveRecord::Associations::ClassMethods::InnerJoinDependency.new(self.class, joins, nil)
    " #{join_dependency.join_associations.collect { |assoc| assoc.association_join }.join} "
  end
  
  def save_with_direct_sql #TODO
    ActiveSupport::Deprecation.warn("save_with_direct_sql (\n#{caller[0..4].join("\n")}\n)")

    quote = Proc.new{|v| self.class.connection.quote(v)}
    
    table = self.class.table_name
    q = self.class.connection.adapter_name == 'Mysql2' ? '`' : '"'
    sql = "INSERT INTO #{table} (#{q}"
    sql += self.class.column_names.sort.join("#{q},#{q}")
    sql += "#{q}) VALUES ("
    
    self.class.column_names.sort.each_with_index do |name, i|
      sql += ',' if i != 0
      value = send(name)
      if value == nil
        sql += 'NULL'
      elsif value.class == Time
        sql += "'#{value.strftime('%Y-%m-%d %H:%M:%S')}'"
      else
        sql += quote.call(value)
      end
    end
    
    sql += ")"
    
    self.class.connection.execute(sql)

    case self.class.connection.adapter_name
    when 'Mysql2'
      rs = self.class.connection.execute("SELECT LAST_INSERT_ID() AS id FROM #{table}")
      rs.first[0]
    when 'PostgreSQL'
      rs = self.class.connection.execute("SELECT LASTVAL() AS id FROM #{table}")
      rs[0].try!(:fetch, 'id')
    end
  end
end
