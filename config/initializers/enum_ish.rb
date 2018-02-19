ActiveSupport.on_load(:active_record) do
  ActiveRecord::Base.extend EnumIsh
end
