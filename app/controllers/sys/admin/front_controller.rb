class Sys::Admin::FrontController < Cms::Controller::Admin::Base
  def index
    @messages = Core.site.messages.where(state: 'public').order(published_at: :desc)

    @maintenances = Core.site.maintenances.where(state: 'public').order(published_at: :desc)

    #@calendar = Util::Date::Calendar.new(nil, nil)
  end
end
