module ControllerHelpers
  module ClassMethods
    def login_as_site_admin
      let(:site_admin) { create(:sys_user, :site_admin) }
      before do
        login_as(site_admin.account)
      end
    end

    def login_as_system_admin
      let(:system_admin) { create(:sys_user, :system_admin) }
      before do
        login_as(system_admin.account)
      end
    end

    def prepare_first_site
      let(:first_site) { create(:cms_site, :first) }
      before do
        initialize_core(first_site.full_uri)
      end
    end
  end

  def self.included(klass)
    klass.extend ClassMethods
  end

  def login_as(account)
    # See Sys::Controller::Admin::Auth#new_login
    user = Sys::User.find_by_account(account)
    session[Sys::Controller::Admin::Auth::ACCOUNT_KEY] = user.account
    session[Sys::Controller::Admin::Auth::PASSWD_KEY] = user.encrypt_password

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
