class Cms::Admin::ExceptionController < Cms::Controller::Admin::Base
  def index
    http_error 404
  end
end
