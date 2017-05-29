source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.0.0.1'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.15'
# Use Puma as the app server
#gem 'puma', '~> 3.0'
# Use Unicorn as the app server
gem 'unicorn'
gem 'unicorn-worker-killer', '~> 0.4.4'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
#gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri

  gem 'factory_girl_rails', '~> 4.7'
  gem 'faker', '~> 1.6', '>= 1.6.3'
  gem 'pry-byebug'
end

group :test do
  gem 'database_rewinder'
  gem 'email_spec', '~> 2.1'
  gem 'rails-controller-testing'
  gem 'rspec-rails', '~> 3.5', '>= 3.5.2'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '~> 2.0'
  gem 'listen', '~> 3.0.5'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem 'bullet'
  gem 'i18n_generators'
  gem 'rails_best_practices'
  gem 'rubocop', require: false
  gem 'brakeman', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'hpricot', '0.8.6'
gem 'tamtam', '0.0.3'

gem 'activerecord-import', '~> 0.17.1'
gem 'addressable', '~> 2.3.8'
gem 'dynamic_form', '~> 1.1.4'
gem 'jpmobile', '~> 5.0.0'
gem 'mail-iso-2022-jp', '~> 2.0.3'
gem 'moji', '~> 1.6'
gem 'nokogiri', '~> 1.6.8.1'
gem 'parallel', '~> 1.6.1'
gem 'rails_autolink', '~> 1.1.6'
gem 'rmagick', '~> 2.15.4'
gem 'rqrcode_png', '~> 0.1.5'
gem 'rubyzip', '~> 1.2.1'
gem 'simple_captcha2', '~> 0.4.2', require: 'simple_captcha'
gem 'will_paginate', '~> 3.1.5'

gem 'delayed_job_active_record', '~> 4.1.1'
gem 'daemons', '~> 1.2.3'
gem 'get_process_mem', '~> 0.2.1'

gem 'faraday', '~> 0.9.2'
gem 'faraday-cookie_jar', '~> 0.0.6'
gem 'faraday_middleware', '~> 0.11.0.1'
gem 'garb', '~> 0.9.8'
gem 'google-oauth2-installed', '0.0.3'
gem 'octokit', '~> 4.6.2'

gem 'whenever', '~> 0.9.7', require: false
gem 'postgres-copy', '~> 1.1.0', require: false

gem 'logical_query_parser', '~> 0.1.0'

# Plugins
Dir.glob(File.join(File.dirname(__FILE__), 'config', 'plugins', '**', "Gemfile")) do |gemfile|
  eval(IO.read(gemfile), binding)
end
