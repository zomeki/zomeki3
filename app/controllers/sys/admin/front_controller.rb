class Sys::Admin::FrontController < Cms::Controller::Admin::Base
  def index
    @messages = Core.site.messages.where(state: 'public').order(published_at: :desc)

    @maintenances = Sys::Maintenance.where(state: 'public').order(published_at: :desc)

    @bookmarks = Sys::Bookmark.roots.where(user_id: Core.user.id).order(:sort_no, :id)

    #@calendar = Util::Date::Calendar.new(nil, nil)
  end
end
