class GpCategory::Public::TemplateModule::BaseController < Sys::Controller::Public::Base
  before_action :set_more_option

  def set_more_option
    @more = (params[:file] =~ /^more($|@)/i)
    @more_options = params[:file].split('@', 3).drop(1) if @more
  end
end
