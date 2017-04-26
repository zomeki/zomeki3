class Cms::Controller::Public::Api < ApplicationController
  layout false
  before_action :pre_dispatch
  
  def pre_dispatch
    ## each processes before dispatch
  end

  def http_error(status)
    render json: { reason: Rack::Utils::HTTP_STATUS_CODES[status] }, status: status
  end
end
