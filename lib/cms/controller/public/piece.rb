class Cms::Controller::Public::Piece < Sys::Controller::Public::Base
  rescue_from ActiveRecord::RecordNotFound, with: -> { render plain: '' }
end
