namespace :db do
  namespace :seed do
    desc 'Reset all data and create a demo'
    task :demo => :environment do
      load "#{Rails.root}/db/seeds/demo.rb"
    end
    desc 'Copy demo to new site'
    task :site => :environment do
      load "#{Rails.root}/db/seeds/site.rb"
    end
  end
end