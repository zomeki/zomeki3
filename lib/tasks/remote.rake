namespace ZomekiCMS::NAME do
  namespace :remote do
    namespace :data do
      desc 'Pull data from remote database'
      task :pull => :environment do
        next if ApplicationRecordSlave.slave_configs.blank?
        Cms::Site.order(:id).pluck(:id).each do |site_id|
          Script.run('survey/answers/pull', site_id: site_id, lock_by: :site)
          Script.run('ad_banner/clicks/pull', site_id: site_id, lock_by: :site)
        end
      end
    end
  end
end
