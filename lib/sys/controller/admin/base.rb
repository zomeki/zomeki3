class Sys::Controller::Admin::Base < ApplicationController
  include Jpmobile::ViewSelector
  include Sys::Controller::Admin::Auth
  before_action :pre_dispatch
  rescue_from ActiveRecord::RecordNotFound, with: :error_auth

  def initialize_application
    return false unless super

    @@current_user = false
    if authenticate
      return false unless current_user
      crypt_pass         = Zomeki.config.application["sys.crypt_pass"]
      Core.user          = current_user
      Core.user.password = Util::String::Crypt.decrypt(session[PASSWD_KEY], crypt_pass)
      Core.user_group    = current_user.groups[0]

      users_session = Sys::UsersSession.new(user_id: Core.user.id, session_id: session.id)
      Sys::UsersSession.bulk_import [users_session], on_duplicate_key_update: { conflict_target: [:user_id, :session_id] }
    end
    return true
  end

  def pre_dispatch
    ## each processes before dispatch
  end

  def self.simple_layout
    self.layout 'admin/base'
  end

  def simple_layout
    self.class.layout 'admin/base'
  end

private
  def authenticate
    return true  if logged_in?
    return false if request.env['PATH_INFO'] =~ Regexp.new("^#{admin_login_path}")
    return false if request.env['PATH_INFO'] =~ Regexp.new("^#{admin_password_path}")
    uri  = request.env['PATH_INFO']
    uri += "?#{request.env['QUERY_STRING']}" if !request.env['QUERY_STRING'].blank?
    cookies[:sys_login_referrer] = { value: uri, httponly: true }
    respond_to do |format|
      format.any  { redirect_to(admin_login_path) }
      format.html { redirect_to(admin_login_path) }
      format.xml  { http_error 500, 'This is a secure page.' }
    end
    return false
  end

  def error_auth
    http_error 403, "アクセス権限がありません。"
  end
end
