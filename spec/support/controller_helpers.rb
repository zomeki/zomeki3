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
end
