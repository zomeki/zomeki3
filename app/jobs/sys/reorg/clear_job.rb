class Sys::Reorg::ClearJob < ApplicationJob
  def perform(site)
    @site = site

    Sys::Reorg::Schedule.where(site: @site).destroy_all
    Organization::Reorg::Group.in_site(@site).find_each(&:destroy)
    Sys::Reorg::User.in_site(@site).find_each(&:destroy)
    Sys::Reorg::Group.in_site(@site).find_each(&:destroy)
  end
end
