class Cms::SiteDestroyService < ApplicationService
  def initialize(site)
    @site = site
  end

  def destroy
    scanned = Cms::SiteScanService.new(@site).scan
    scanned.each do |model, ids|
      next if model.in?([Sys::Group, Sys::UsersGroup, Sys::User, Sys::UsersSession])
      model.unscoped.where(id: ids).delete_all if ids.present?
    end

    # destroy isolated groups
    scanned[Sys::Group].each do |group_id|
      next if Cms::SiteBelonging.where(group_id: group_id).exists?
      Sys::Group.where(id: group_id).destroy_all
      Sys::UsersGroup.where(group_id: group_id).destroy_all
    end

    # destroy isolated users
    scanned[Sys::User].each do |user_id|
      next if Sys::UsersGroup.where(user_id: user_id).exists?
      Sys::User.where(id: user_id).destroy_all
    end
  end
end
