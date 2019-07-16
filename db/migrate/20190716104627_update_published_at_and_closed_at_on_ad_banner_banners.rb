class UpdatePublishedAtAndClosedAtOnAdBannerBanners < ActiveRecord::Migration[5.0]
  def up
    now = Time.now
    arel_table = AdBanner::Banner.arel_table

    items = AdBanner::Banner.where(arel_table[:state].eq('closed')
                            .or(arel_table[:closed_at].lteq(now))).all
    items.each do |item|
      if (item.state_closed? && item.published_at.blank? && item.closed_at.blank?) ||
        (item.published_at.present? && item.closed_at.present? && item.published_at > now && item.closed_at > now)
        item.update_columns(state: 'draft')
      else
        item.update_columns(state: 'closed') if item.state_public?
      end
      
      if item.published_at.present?
        item.tasks.create(name: 'publish', process_at: item.published_at, state: 'performed') if item.published_at < now
        item.tasks.create(name: 'publish', process_at: item.published_at, state: 'queued') if item.published_at > now
      end
      if item.closed_at.present?
        item.tasks.create(name: 'close', process_at: item.closed_at, state: 'performed') if item.closed_at < now
        item.tasks.create(name: 'close', process_at: item.closed_at, state: 'queued') if item.closed_at > now
      end
    end
    
    items = AdBanner::Banner.where(state: 'public').all
    items.each do |item|
      if item.published_at.present?
        if item.published_at > now
          item.tasks.create(name: 'publish', process_at: item.published_at, state: 'queued')
          item.update_columns(state: 'prepared')
        end
        item.tasks.create(name: 'publish', process_at: item.published_at, state: 'performed') if item.published_at < now
      end
      if item.closed_at.present?
        item.tasks.create(name: 'close', process_at: item.closed_at, state: 'performed') if item.closed_at < now
        item.tasks.create(name: 'close', process_at: item.closed_at, state: 'queued') if item.closed_at > now
      end
      item.queued_tasks.each(&:enqueue_job)
    end
  end

  def down
  end
end
