namespace :zomeki do
  namespace :rank do
    namespace :ranks do
      desc 'Fetch ranking'
      task :exec => :environment do
        Cms::Site.order(:id).pluck(:id).each do |site_id|
          Script.run('rank/ranks/exec', site_id: site_id, lock_by: :site)
        end
      end
    end
  end
end
