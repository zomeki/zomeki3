class UpdateLogicOnMailinFilters < ActiveRecord::Migration[5.0]
  def change
    execute "update mailin_filters set logic = 'and'"
  end
end
