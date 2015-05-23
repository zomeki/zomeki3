module Helpers
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

  def fg_find_or_create(fg_id)
    klass = FactoryGirl.build(fg_id).class
    klass.find_by_id(FactoryGirl.attributes_for(fg_id)[:id]) || FactoryGirl.create(fg_id)
  end

  def initialize_core(script_uri)
    uri = URI.parse(script_uri)

    env = {'SCRIPT_URI' => script_uri,
           'PATH_INFO' => uri.path,
           'QUERY_STRING' => '',
           'REQUEST_URI' => uri.path,
           'SERVER_PROTOCOL' => 'HTTP/1.1',
           'HTTP_COOKIE' => ''}

    Core.initialize(env)
    Core.recognize_path(env['PATH_INFO'])
  end
end
