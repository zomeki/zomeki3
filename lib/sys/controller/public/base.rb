class Sys::Controller::Public::Base < ApplicationController
  include Jpmobile::ViewSelector

  layout false
  before_action :pre_dispatch
  rescue_from ActiveRecord::RecordNotFound, with: -> { http_error(404) }

  def pre_dispatch
    ## each processes before dispatch
  end
end
