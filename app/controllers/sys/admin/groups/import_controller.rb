require 'csv'
class Sys::Admin::Groups::ImportController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
  end

  def index
  end

  def import
    if !params[:item] || !params[:item][:file]
      return redirect_to(action: :index)
    end

    @results = [0, 0, 0]

    import_params = params.require(:item).permit(:file)

    require 'nkf'
    csv = NKF.nkf('-w', import_params[:file].read)

    if params[:do] == 'groups'
      Core.messages << "インポート： グループ"
      import_groups(csv)
    elsif params[:do] == 'users'
      Core.messages << "インポート： ユーザー"
      import_users(csv)
    else
      return redirect_to(action: :index)
    end

    Core.messages << "-- 追加 #{@results[0]}件"
    Core.messages << "-- 更新 #{@results[1]}件"
    Core.messages << "-- 失敗 #{@results[2]}件"

    flash[:notice] = "インポートが終了しました。<br />#{Core.messages.join('<br />')}".html_safe
    return redirect_to(action: :index)
  end

  def import_groups(csv)
    CSV.parse(csv, headers: true, header_converters: :symbol) do |data|
      code        = data[:code]
      parent_code = data[:parent_code]

      if code.blank?
        @results[2] += 1
        next
      end

      if parent_code.present?
        unless parent = Sys::Group.in_site(Core.site).find_by(code: parent_code)
          @results[2] += 1
          next
        end
      else
        unless Sys::Group.in_site(Core.site).where(code: code).exists?
          @results[2] += 1
          next
        end
      end

      group = Sys::Group.in_site(Core.site).find_by(code: code) || Sys::Group.new(code: code)
      group.parent_id    = parent.try(:id).to_i
      group.state        = data[:state]
      group.level_no     = data[:level_no]
      group.sort_no      = data[:sort_no]
      group.ldap         = data[:ldap]
      group.ldap_version = data[:ldap_version]
      group.name         = data[:name]
      group.name_en      = data[:name_en]
      group.address      = data[:address]
      group.tel          = data[:tel]
      group.tel_attend   = data[:tel_attend]
      group.fax          = data[:fax]
      group.email        = data[:email]
      group.note         = data[:note]

      group.sites << Core.site if group.new_record?
      
      next unless group.changed?
      status = group.new_record? ? 0 : 1
      if group.save
        @results[status] += 1
      else
        @results[2] += 1
      end
    end
  end
  
  def import_users(csv)
    CSV.parse(csv, headers: true, header_converters: :symbol) do |data|
      account     = data[:account]
      group_code  = data[:group_code]

      if account.blank? || group_code.blank?
        @results[2] += 1
        next
      end

      unless group = Sys::Group.in_site(Core.site).find_by(code: group_code)
        @results[2] += 1
        next
      end

      user = Sys::User.in_site(Core.site).find_by(account: account) || Sys::User.new(account: account)
      user.state        = data[:state]
      user.ldap         = data[:ldap]
      user.ldap_version = data[:ldap_version]
      user.auth_no      = data[:auth_no]
      user.name         = data[:name]
      user.name_en      = data[:name_en]
      user.password     = data[:password]
      user.email        = data[:email]

      ug = user.users_groups[0] || user.users_groups.build
      ug.group = group

      if user.password == 'RANDOM'
        user.password = SecureRandom.base64(8).slice(0, 8)
      end

      if Core.user.root?
        user.admin_creatable = data[:admin_creatable] if data.include?(:admin_creatable)
      end

      next if !user.changed? && !ug.changed?

      status = user.new_record? ? 0 : 1
      status = 2 unless user.save
      
      @results[status] += 1
    end
  end
end
