namespace :zomeki do
  desc 'Configure zomeki'
  task configure: :environment do
    Rake::Task['zomeki:configure:apache'].invoke
    Rake::Task['zomeki:configure:nginx'].invoke
    Rake::Task['zomeki:configure:tika'].invoke
  end

  namespace :configure do
    task :apache do
      Pathname.glob(Rails.root.join('config/apache/*.erb')).each do |erb|
        next unless erb.file?
        erb.sub_ext('').write(ERB.new(erb.read, nil, '-').result(binding))
      end
      Cms::Site.generate_apache_configs
    end

    task :nginx do
      Pathname.glob(Rails.root.join('config/nginx/*.erb')).each do |erb|
        next unless erb.file?
        erb.sub_ext('').write(ERB.new(erb.read, nil, '-').result(binding))
      end
      Cms::Site.generate_nginx_configs
    end

    task :tika do
      url = 'http://ftp.meisei-u.ac.jp/mirror/apache/dist/tika/tika-app-1.13.jar'
      print 'Downloading Apache Tika...'
      `cd #{Rails.root.join('vendor/tika')} && curl -fsSLo tika-app.jar #{url}`
      puts 'done!'
    end
  end
end
