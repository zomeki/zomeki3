source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.2.2'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server
#gem 'puma', '~> 3.0'
# Use Unicorn as the app server
gem 'unicorn', '~> 5.4.0'
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
#gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri

  gem 'factory_girl_rails', '~> 4.7'
  gem 'faker', '~> 1.6', '>= 1.6.3'
  gem 'pry-byebug'
end

group :test do
  gem 'database_rewinder'
  gem 'email_spec', '~> 2.2'
  gem 'rails-controller-testing'
  gem 'rspec-rails', '~> 3.5', '>= 3.5.2'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'

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

gem 'active_record_union', '~> 1.3.0'
gem 'activerecord-import', '~> 0.27.0'
gem 'addressable', '~> 2.5.2'
gem 'holiday_jp', '~> 0.7.0'
gem 'jpmobile', '~> 5.2.2'
gem 'mail', '~> 2.7.0'
gem 'mail-iso-2022-jp', '~> 2.0.8'
gem 'moji', '~> 1.6'
gem 'nokogiri', '~> 1.8.5'
gem 'parallel', '~> 1.12.1'
gem 'rails_autolink', '~> 1.1.6'
gem 'rmagick', '~> 2.15.4'
gem 'rqrcode_png', '~> 0.1.5'
gem 'rubyzip', '~> 1.2.2'
gem 'simple_captcha2', '~> 0.4.3', require: 'simple_captcha'
gem 'will_paginate', '~> 3.1.6'
gem 'romaji', '~> 0.2.4'
gem 'timecop', '~> 0.9.1'

gem 'browser', '~> 2.5.3'
gem 'dynamic_form', '~> 1.1.4'
gem 'rails-i18n', '~> 5.1.1'
gem 'sanitize', '~> 4.6.4'

gem 'delayed_job', '~> 4.1.5'
gem 'delayed_job_active_record', '~> 4.1.3'
gem 'delayed_job_master', '~> 1.1.0', require: false

gem 'faraday', '~> 0.9.2'
gem 'faraday_middleware', '~> 0.11.0.1'
gem 'garb', '~> 0.9.8'
gem 'google-oauth2-installed', '0.0.3'
gem 'octokit', '~> 4.13.0', require: false
gem 'tika-client', '~> 0.2.0', require: false

gem 'whenever', '~> 0.10.0', require: false

gem 'activerecord_nested_scope', '~> 1.0.4'
gem 'logical_query_parser', '~> 0.2.0'
gem 'params_keeper_rails', '~> 1.1.1'
gem 'datewari', '~> 1.0.2'
gem 'enum_ish', '~> 1.1.0'
gem 'slonik_migration', '~> 1.1.2'

gem 'zplugin3-sitebk', git: 'https://github.com/zomeki/zplugin3-sitebk', tag: 'v1.0.0'

Dir[File.join(File.dirname(__FILE__), 'config/plugins/**/Gemfile')].each do |file|
  instance_eval File.read(file)
end
