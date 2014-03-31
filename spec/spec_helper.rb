# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  config.before(:all) do
    FactoryGirl.reload
  end

  require 'email_spec'
  config.include(EmailSpec::Helpers)
  config.include(EmailSpec::Matchers)
end

def login_as(account)
  # See Sys::Controller::Admin::Auth#new_login
  user = Sys::User.find_by_account(account)
  return nil unless user
  if defined?(session)
    session[Sys::Controller::Admin::Base::ACCOUNT_KEY] = user.account
    session[Sys::Controller::Admin::Base::PASSWD_KEY] = user.encrypt_password
  end

  # See Sys::Controller::Admin::Base#initialize_application
  Core.user = user
  Core.user.password = Util::String::Crypt.decrypt(user.encrypt_password, Zomeki.config.application['sys.crypt_pass'])
  Core.user_group = user.group
  return user
end

# TODO: 相応しい実装が思いついたときに移動する
def fg_find_or_create(fg_id)
  klass = FactoryGirl.build(fg_id).class
  klass.find_by_id(FactoryGirl.attributes_for(fg_id)[:id]) || FactoryGirl.create(fg_id)
end
