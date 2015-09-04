class Sys::Controller::Public::Base < ApplicationController
  include Jpmobile::ViewSelector
  
  layout false
  before_action :pre_dispatch
  
  def pre_dispatch
    ## each processes before dispatch
  end
end
