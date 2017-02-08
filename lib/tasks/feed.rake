namespace :zomeki do
  namespace :feed do
    namespace :feeds do
      desc 'Read feeds'
      task :read => [:environment, :init_core] do
        Script.run('feed/feeds/read')
      end
    end
  end
end
