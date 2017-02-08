namespace :zomeki do
  namespace :ad_banner do
    namespace :clicks do
      desc 'Fetch ad_banner clicks'
      task :pull => :environment do
        Script.run('ad_banner/clicks/pull')
      end
    end
  end
end
