namespace :zomeki do
  task :init_core do
    Core.initialize
  end

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
      download_index_url = 'https://tika.apache.org/download.html'
      jar_index_url = Nokogiri::HTML(Net::HTTP.get(URI.parse download_index_url)).css('a.externalLink[href$=".jar"]').attr('href').text
      puts jar_url = Nokogiri::HTML(Net::HTTP.get(URI.parse jar_index_url)).css('a[href$=".jar"]').attr('href').text

      print 'Downloading Apache Tika...'
      `cd #{Rails.root.join('vendor/tika')} && curl -fsSLo tika-app.jar #{jar_url}`
      puts 'done!'
    end
  end
end
