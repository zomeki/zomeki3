class Cms::Controller::Public::Base < Sys::Controller::Public::Base
  include Cms::Controller::Layout

  before_action :initialize_params
  after_action :render_public_variables
  after_action :render_public_layout

  def initialize_params
    if m = Page.uri.match(/\.p(\d+)\.html(\.r)?\z/)
      page = m[1].to_i
      params[:page] = page if page > 0
    end
    if d = Page.uri.match(/\.(\d+)\.html(\.r)?\z/)
      date = d[1].to_s
      params[:date] = date
    end
  end

  def pre_dispatch
    ## each processes before dispatch
  end

  def render_public_variables
  end
end
