class ExceptionController < ApplicationController
  def index
    http_error 404
    
    #dump "====== Exceptin: #{request.env['REQUEST_URI']}"
    #render :inline => "Exception: #{request.env['REQUEST_URI']}"
  end
end
