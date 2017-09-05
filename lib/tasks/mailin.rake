namespace ZomekiCMS::NAME do
  namespace :mailin do
    namespace :filters do
      desc 'Fetch mails and filter them'
      task :exec => :environment do
        startup = Time.now
        sites = Cms::Site.order(:id)
        sites.where!(id: ENV['SITE_ID']) if ENV['SITE_ID']
        sites.each do |site|
          Script.run('mailin/filters/exec', site_id: site.id, lock_by: :site, startup: startup)
        end
      end
    end
  end
end
