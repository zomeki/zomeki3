##---------------------------------------------------------
##truncate
exclusions = %w(ar_internal_metadata schema_migrations)
ActiveRecord::Base.connection.tables.each do |table|
  next if exclusions.include?(table)
  ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table} RESTART IDENTITY;")
end
