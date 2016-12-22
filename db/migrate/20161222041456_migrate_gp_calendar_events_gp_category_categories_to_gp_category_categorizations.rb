class MigrateGpCalendarEventsGpCategoryCategoriesToGpCategoryCategorizations < ActiveRecord::Migration[5.0]
  def up
    execute <<-SQL
      insert into gp_category_categorizations (categorizable_id, categorizable_type, category_id, created_at, updated_at)
        select event_id, 'GpCalendar::Event', category_id, now(), now() from gp_calendar_events_gp_category_categories;
    SQL
  end
  def down
  end
end
