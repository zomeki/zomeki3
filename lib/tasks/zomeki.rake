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
      Rails::Generators.invoke('cms:apache:base_config', ['--force'])
      Rails::Generators.invoke('cms:apache:site_config', ['--force'])
    end

    task :nginx do
      Rails::Generators.invoke('cms:nginx:base_config', ['--force'])
      Rails::Generators.invoke('cms:nginx:site_config', ['--force'])
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
