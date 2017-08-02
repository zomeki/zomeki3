namespace ZomekiCMS::NAME do
  namespace :db do
    namespace :site do
      desc 'Dump site (options: SITE_ID=x, DIR=x)'
      task :dump => :environment do
        site = Cms::Site.where(id: ENV['SITE_ID']).first_or_initialize

        puts "dumping site id: #{site.id}..."
        Cms::Tasks::Site::Backupper.new(site, dir: ENV['DIR'] || ENV['HOME'] || Rails.root).dump do |model, ids, path|
          puts "#{model.table_name}: #{ids.size} rows to '#{path}'"
        end
        puts "done."
      end

      desc 'Dump all sites (options: DIR=x)'
      task :dump_all => :environment do
        Cms::Site.order(:id).each do |site|
          ENV['SITE_ID'] = site.id.to_s
          Rake::Task["#{ZomekiCMS::NAME}:db:site:dump"].reenable
          Rake::Task["#{ZomekiCMS::NAME}:db:site:dump"].invoke
        end
      end

      desc 'Restore site  (options: SITE_ID=x, DIR=x)'
      task :restore => :environment do
        site = Cms::Site.new(id: ENV['SITE_ID'])

        puts "restoring site id: #{site.id}..."
        Cms::Tasks::Site::Backupper.new(site, dir: ENV['DIR'] || ENV['HOME'] || Rails.root).restore do |model, ids, path|
          puts "#{model.table_name}: #{ids.size} rows from '#{path}'"
        end
        puts "done."
      end
    end
  end
end
