require 'nkf'
require 'csv'
class Sys::Admin::Groups::ExportController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  
  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
  end
  
  def index
    
  end
 
  def export
    if params[:do] == 'groups'
      csv = export_groups
      send_data platform_encode(csv), type: 'text/csv', filename: "sys_groups_#{Time.now.to_i}.csv"
    elsif params[:do] == 'users'
      csv = export_users
      send_data platform_encode(csv), type: 'text/csv', filename: "sys_users_#{Time.now.to_i}.csv"
    else
      return redirect_to(:action => :index)
    end
  end

  def export_groups
    CSV.generate do |csv|
      csv << [:code, :parent_code, :state, :level_no, :sort_no,:ldap,
              :ldap_version, :name, :name_en, :address, :tel, :tel_attend, :fax,
              :email, :note]

      groups = Core.site.groups.to_tree.flat_map(&:descendants)
      groups.each do |group|
        row = []
        row << group.code
        row << group.parent.try!(:code)
        row << group.state
        row << group.level_no
        row << group.sort_no
        row << group.ldap
        row << group.ldap_version
        row << group.name
        row << group.name_en
        row << group.address
        row << group.tel
        row << group.tel_attend
        row << group.fax
        row << group.email
        row << group.note
        csv << row
      end
    end
  end

  def export_users
    CSV.generate do |csv|
      csv << if Core.user.root?
               [:account, :state, :name, :name_en, :email, :auth_no, :password, :ldap, :ldap_version,
                :group_code, :admin_creatable]
             else
               [:account, :state, :name, :name_en, :email, :auth_no, :password, :ldap, :ldap_version,
                :group_code]
             end

      users = Core.site.users.where.not(id: Sys::User::ROOT_ID).order(:id).preload(:groups)
      users.each do |user|
        next unless user.groups[0]
        row = []
        row << user.account
        row << user.state
        row << user.name
        row << user.name_en
        row << user.email
        row << user.auth_no
        row << user.password
        row << user.ldap
        row << user.ldap_version
        row << user.groups[0].code
        row << user.admin_creatable if Core.user.root?
        csv << row
      end
    end
  end
end
