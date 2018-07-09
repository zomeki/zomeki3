class Sys::Admin::LdapSynchrosController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  
  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
    return render(html: "LDAPサーバーに接続できません。", layout: true) unless Core.ldap.connection
  end
  
  def index
    @items = Sys::LdapSynchro.select("DISTINCT ON (version) *").order(version: :desc)
      .paginate(page: params[:page], per_page: params[:limit])
    _index @items
  end
  
  def show
    @version = params[:id]

    @items = Sys::LdapSynchro.where(version: @version, parent_id: 0, entry_type: 'group').order(:sort_no, :code)

    _show @items
  end

  def new
    @item = Sys::LdapSynchro.new
  end
  
  def create
    @version = Time.now.strftime('%s')
    @results = { group: 0, user: 0, error: 0 }
    error   = nil
    
    begin
      create_synchros
    rescue ActiveLdap::LdapError::AdminlimitExceeded
      error = "LDAP通信時間超過"
    rescue
      error = ""
    end
    
    if error.nil?
      messages = ["中間データを作成しました。"]
      messages << "-- グループ #{@results[:group]}件"
      messages << "-- ユーザー #{@results[:user]}件"
      messages << "-- エラー #{@results[:error]}件" if @results[:error] > 0
      flash[:notice] = messages.join('<br />').html_safe
      redirect_to url_for(action: :show, id: @version)
    else
      flash[:notice] = "中間データの作成に失敗しました。［ #{error} ］"
      redirect_to url_for(action: :index)
    end
  end
  
  def update
    
  end
  
  def destroy
    Sys::LdapSynchro.where(version: params[:id]).delete_all
    flash[:notice] = "削除処理が完了しました。"
    redirect_to url_for(action: :index)
  end
  
  def synchronize
    @version = params[:id]
    
    @items = Sys::LdapSynchro.where(version: @version, parent_id: 0, entry_type: 'group').order(:sort_no, :code)
    
    unless parent = Sys::Group.find_by(parent_id: 0)
      return render inline: "グループのRootが見つかりません。", layout: true
    end
    
    Sys::Group.update_all(ldap_version: nil)
    Sys::User.update_all(ldap_version: nil)
    
    @results = { group: 0, gerr: 0, user: 0, uerr: 0 }
    @items.each { |group| do_synchro(group, parent) }
    
    @results[:udel] = Sys::User.where(ldap: 1, ldap_version: nil).destroy_all.size
    @results[:gdel] = Sys::Group.where.not(parent_id: 0).where(ldap: 1, ldap_version: nil).destroy_all.size
    
    messages = ["同期処理が完了しました。<br />"]
    messages << "グループ"
    messages << "-- 更新 #{@results[:group]}件"
    messages << "-- 削除 #{@results[:gdel]}件" if @results[:gdel] > 0
    messages << "-- 失敗 #{@results[:gerr]}件" if @results[:gerr] > 0
    messages << "ユーザー"
    messages << "-- 更新 #{@results[:user]}件"
    messages << "-- 削除 #{@results[:udel]}件" if @results[:udel] > 0
    messages << "-- 失敗 #{@results[:uerr]}件" if @results[:uerr] > 0
    flash[:notice] = messages.join('<br />').html_safe
    
    redirect_to(action: :index)
  end
  
protected
  def do_synchro(group, parent = nil)
    ## group
    sg                = Sys::Group.find_by(code: group.code) || Sys::Group.new
    sg.code           = group.code
    sg.parent_id      = parent.id
    sg.state        ||= 'enabled'
    sg.web_state    ||= 'public'
    sg.name           = group.name
    sg.name_en        = group.name_en if !group.name_en.blank?
    sg.email          = group.email if !group.email.blank?
    sg.level_no       = parent.level_no + 1
    #sg.sort_no        = group.sort_no
    sg.ldap         ||= 1
    sg.ldap_version   = @version
    
    if sg.ldap == 1
      if sg.save(validate: false)
        @results[:group] += 1
      else
        @results[:gerr] += 1
        return false
      end
    end
    
    ## users
    if group.users.size > 0
      group.users.each do |user|
        su                = Sys::User.find_by(account: user.code) || Sys::User.new
        su.account        = user.code
        su.state        ||= 'enabled'
        su.auth_no      ||= 2
        su.name           = user.name
        su.name_en        = user.name_en
        su.email          = user.email
        su.ldap         ||= 1
        su.ldap_version   = @version

        ug = user.users_groups[0] || user.users_groups.build
        ug.group = sg

        if su.ldap == 1
          if su.save
            @results[:user] += 1
          else
            @results[:uerr] += 1
          end
        end
      end
    end
    
    ## next
    if group.children.size > 0
      group.children.each {|g| do_synchro(g, sg)}
    end
  end
  
  def create_synchros(entry = nil, group_id = nil)
    if entry.nil?
      Core.ldap.group.children.each do |e|
        create_synchros(e, 0)
      end
      return true
    end
    
    group = Sys::LdapSynchro.new(
      parent_id:  group_id,
      version:    @version,
      entry_type: 'group',
      code:       entry.code,
      name:       entry.name,
      name_en:    entry.name_en,
      email:      entry.email
    )
    unless group.save
      @results[:error] += 1
      return false
    end
    @results[:group] += 1
    
    entry.users.each do |e|
      user = Sys::LdapSynchro.new(
        parent_id:  group.id,
        version:    @version,
        entry_type: 'user',
        code:       e.uid,
        name:       e.name,
        name_en:    e.name_en,
        email:      e.email
      )
      user.save ? @results[:user] += 1 : @results[:error] += 1
    end
    
    entry.children.each do |e|
      create_synchros(e, group.id)
    end
  end
end
