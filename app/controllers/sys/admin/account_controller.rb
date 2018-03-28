class Sys::Admin::AccountController < Sys::Controller::Admin::Base
  layout 'admin/login'

  def login
    return redirect_to(admin_root_path) if logged_in?

    @uri = params[:uri] || cookies[:sys_login_referrer] || admin_root_path
    @uri = @uri.gsub(/^http:\/\/[^\/]+/, '')
    return unless request.post?

    unless new_login(params[:account], params[:password])
      flash.now[:alert] = 'ユーザーＩＤ・パスワードを正しく入力してください。'
      respond_to do |format|
        format.html { render }
        format.xml  { render(xml: '<errors />') }
      end
      return true
    end

    if Sys::Setting.is_maintenance_mode? && !current_user.root?
      logout
      return true
    end

    if params[:remember_me] == "1"
      self.current_user.remember_me
      cookies[:auth_token] = {
        value: self.current_user.remember_token,
        expires: self.current_user.remember_token_expires_at
      }
    end

    cookies.delete :sys_login_referrer
    Sys::OperationLog.log(request, user: current_user)

    respond_to do |format|
      format.html { redirect_to @uri }
      format.xml  { render(xml: current_user.to_xml) }
    end
  end

  def logout
    if logged_in?
      current_user.forget_me
      current_user.users_sessions.where(session_id: session.id).delete_all
    end

    cookies.delete :auth_token
    cookies.delete :cms_site
    reset_session

    Sys::OperationLog.log(request, user: current_user)
    redirect_to(action: :login)
  end

  def info
    respond_to do |format|
      format.html { render }
      format.xml  { render xml: Core.user.to_xml(root: 'item', include: :groups) }
    end
  end

  def new_password_reminder
  end

  def create_password_reminder
    if params[:account].blank? || params[:email].blank?
      redirect_to new_admin_password_reminder_url, alert: 'ユーザーIDと登録されているメールアドレスを<br />入力してください。'.html_safe
      return
    end

    sender = Core.site.admin_mail_sender
    user   = Sys::User.where(account: params[:account], email: params[:email]).first

    if (email = user.try(:email))
      token = Util::String::Token.generate_unique_token(Sys::User, :reset_password_token)
      user.update_column(:reset_password_token_expires_at, 12.hours.since)
      user.update_column(:reset_password_token, token)

      body = <<-EOT
パスワード変更を受け付けました。12時間以内に下記URLから変更を行ってください。

#{edit_admin_password_url(token: token)}
      EOT

      send_mail(sender, email, "【#{Core.site.try(:name).presence || 'CMS'}】パスワード再設定", body)
    end

    redirect_to admin_login_url, notice: 'メールにてパスワード再設定手順をお送りしました。'
  end

  def edit_password
    @token = params[:token]

    users = Sys::User.arel_table
    user = Sys::User.where(users[:reset_password_token].eq(@token).and(users[:reset_password_token_expires_at].gt(Time.now))).first

    redirect_to admin_login_url, alert: 'URLが正しくないか再設定期限が切れています。' unless user
  end

  def update_password
    @token = params[:token]

    users = Sys::User.arel_table
    user = Sys::User.where(users[:reset_password_token].eq(@token).and(users[:reset_password_token_expires_at].gt(Time.now))).first

    unless user
      redirect_to admin_login_url, alert: 'URLが正しくないか再設定期限を過ぎています。'
    else
      password = params[:password]
      password_confirmation = params[:password_confirmation]

      if password.blank? || password_confirmation.blank?
        flash[:alert] = 'パスワードを入力してください。'
        render :edit_password
      elsif password != password_confirmation
        flash[:alert] = 'パスワードが一致しません。'
        render :edit_password
      elsif user.password == password
        flash[:alert] = '現在のパスワードと同じパスワードは使用できません。'
        render :edit_password
      else
        user.update_column(:reset_password_token_expires_at, nil)
        user.update_column(:reset_password_token, nil)
        user.update_column(:password, password)
        redirect_to admin_login_url, notice: 'パスワードを再設定しました。'
      end
    end
  end
end
