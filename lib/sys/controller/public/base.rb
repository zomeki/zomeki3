class Sys::Controller::Public::Base < ApplicationController
  include Jpmobile::ViewSelector

  layout false
  before_action :pre_dispatch
  before_action :set_page_variables
  rescue_from ActiveRecord::RecordNotFound, with: -> { http_error(404) }

  def pre_dispatch
    ## each processes before dispatch
  end

  private

  def set_page_variables
    Page.mobile = true if request.mobile?
    Page.smart_phone = true if request.smart_phone?
  end
end
