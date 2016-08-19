namespace :zomeki do
  namespace :feed do
    namespace :feeds do
      desc 'Read feeds'
      task(:read => :environment) do
        Script.run('feed/script/feeds/read')
      end
    end
  end
end
