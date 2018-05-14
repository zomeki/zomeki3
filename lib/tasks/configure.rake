namespace ZomekiCMS::NAME do
  task :init_core do
    Core.initialize
  end

  desc 'Configure'
  task configure: :environment do
    Rake::Task["#{ZomekiCMS::NAME}:configure:apache"].invoke
    Rake::Task["#{ZomekiCMS::NAME}:configure:nginx"].invoke
  end

  namespace :configure do
    task apache: :environment do
     `cp #{Rails.root.join('config/apache/samples/*')} #{Rails.root.join('config/apache/')}`
     `sed -i -e "s/\\/var\\/www\\/zomeki/#{Rails.root.to_s.gsub('/', '\\/')}/g" #{Rails.root.join('config/apache/apache.conf')}`
      Rails::Generators.invoke('cms:apache:site_config', ['--force'])
    end

    task nginx: :environment do
     `cp #{Rails.root.join('config/nginx/samples/*')} #{Rails.root.join('config/nginx/') }`
     `sed -i -e "s/\\/var\\/www\\/zomeki/#{Rails.root.to_s.gsub('/', '\\/')}/g" #{Rails.root.join('config/nginx/nginx.conf')}`
      Rails::Generators.invoke('cms:nginx:site_config', ['--force'])
    end
  end
end
