namespace :zomeki do
  desc 'Configure zomeki'
  task configure: :environment do
    Rake::Task['zomeki:configure:nginx'].invoke
  end

  namespace :configure do
    task :nginx do
      Pathname.glob(Rails.root.join('config/nginx/*.erb')).each do |erb|
        next unless erb.file?
        erb.sub_ext('').write(ERB.new(erb.read, nil, '-').result(binding))
      end
      Cms::Site.update_nginx_configs
    end
  end
end
