module Helpers
  def login_as(account)
    # See Sys::Controller::Admin::Auth#new_login
    user = Sys::User.find_by_account(account)
# TODO: SystemStackError: stack level too deep
#    session[Sys::Controller::Admin::Auth::ACCOUNT_KEY] = user.account
#    session[Sys::Controller::Admin::Auth::PASSWD_KEY] = user.encrypt_password

    # See Sys::Controller::Admin::Base#initialize_application
    Core.user = user
    Core.user.password = Util::String::Crypt.decrypt(user.encrypt_password, Zomeki.config.application['sys.crypt_pass'])
    Core.user_group = user.group

    return user
  end

  def initialize_core(uri)
    parsed_uri = URI.parse(uri)

    # All of keys are used in lib/core.rb
    env = {'rack.url_scheme' => parsed_uri.scheme,
           'HTTP_X_FORWARDED_HOST' => parsed_uri.host,
           'HTTP_HOST' => parsed_uri.host,
           'REQUEST_URI' => parsed_uri.path,
           'PATH_INFO' => parsed_uri.path,
           'QUERY_STRING' => '',
           'SERVER_PROTOCOL' => 'HTTP/1.1',
           'HTTP_COOKIE' => ''}

    Core.initialize(env)
    Core.recognize_path(env['PATH_INFO'])
  end
end
