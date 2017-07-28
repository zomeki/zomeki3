class Cms::Public::ExceptionController < Cms::Controller::Public::Base
  def index
    http_error 404
  end
end
