namespace ZomekiCMS::NAME do
  task :init_core do
    Core.initialize
  end

  desc 'Configure'
  task configure: :environment do
    Rake::Task["#{ZomekiCMS::NAME}:configure:apache"].invoke
    Rake::Task["#{ZomekiCMS::NAME}:configure:nginx"].invoke
    Rake::Task["#{ZomekiCMS::NAME}:configure:certs"].invoke
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

    task certs: :environment do
      Dir.chdir(Rails.root.join('config/nginx/certs')) do
        `openssl genrsa -des3 -passout pass:common -out common.key 2048`
        `openssl rsa -passin pass:common -in common.key -out common.key`
        `openssl req -new -sha256 -key common.key -out common.csr -subj "/C=JP/ST=COMMON/L=COMMON/O=COMMON/OU=COMMON/CN=COMMON"`
        `openssl x509 -req -in common.csr -signkey common.key -sha256 -days 36500 -out common.crt`
      end
    end
  end
end
