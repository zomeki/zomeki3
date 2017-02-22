class GpTemplate::Admin::FormsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    @content = GpTemplate::Content::Template.find(params[:content])
    @template = @content.templates.find(params[:template_id]) if params[:template_id].present?
  end

  def build
    @template_values = params[:item] && params[:item][:template_values] ? params[:item][:template_values] : {}
    render 'build', layout: false
  end
end
