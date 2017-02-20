namespace :zomeki do
  namespace :feed do
    namespace :feeds do
      desc 'Read feeds'
      task :read => [:environment, :init_core] do
        Cms::Site.order(:id).pluck(:id).each do |site_id|
          Script.run('feed/feeds/read', site_id: site_id, lock_by: :site)
        end
      end
    end
  end
end
