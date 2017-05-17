namespace :zomeki do
  namespace :gp_calendar do
    desc 'Publish todays events'
    task :publish_todays_events => :environment do
      Cms::Site.order(:id).pluck(:id).each do |site_id|
        node_ids = Cms::Node.public_state.where(site_id: site_id, model: 'GpCalendar::TodaysEvent').pluck(:id)
        Script.run("cms/nodes/publish", site_id: site_id, target_node_id: node_ids, lock_by: :site) if node_ids.present?
      end
    end
  end
end
