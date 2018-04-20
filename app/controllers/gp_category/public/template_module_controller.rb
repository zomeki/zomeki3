class GpCategory::Public::TemplateModuleController < Sys::Controller::Public::Base
  include GpArticle::Controller::Public::Scoping

  before_action :set_more_option

  def set_more_option
    @more = (params[:file] =~ /^more($|@)/i)
    @more_options = params[:file].split('@', 3).drop(1) if @more
  end
end
