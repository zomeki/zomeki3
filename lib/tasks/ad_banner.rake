namespace :zomeki do
  namespace :ad_banner do
    namespace :clicks do
      desc 'Fetch ad_banner clicks'
      task :pull => :environment do
        next if ApplicationRecordSlave.slave_configs.blank?
        Cms::Site.order(:id).pluck(:id).each do |site_id|
          Script.run('ad_banner/clicks/pull', site_id: site_id, lock_by: :site)
        end
      end
    end
  end
end
