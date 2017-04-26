namespace :zomeki do
  namespace :survey do
    namespace :answers do
      desc 'Fetch survey answers'
      task :pull => :environment do
        next if ApplicationRecordSlave.slave_configs.blank?
        Cms::Site.order(:id).pluck(:id).each do |site_id|
          Script.run('survey/answers/pull', site_id: site_id, lock_by: :site)
        end
      end
    end
  end
end
