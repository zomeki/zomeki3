class UpdateCmsPeriods < ActiveRecord::Migration[5.0]
  def up
    execute "insert into cms_periods (periodable_type, periodable_id, started_on, ended_on, created_at, updated_at)
      select 'GpArticle::Doc', id, event_started_on, event_ended_on, created_at, updated_at from gp_article_docs where event_started_on is not null and event_ended_on is not null"

    execute "insert into cms_periods (periodable_type, periodable_id, started_on, ended_on, created_at, updated_at)
      select 'GpCalendar::Event', id, started_on, ended_on, created_at, updated_at from gp_calendar_events where started_on is not null and ended_on is not null"
  end

  def down
  end
end
