# encoding: utf-8
module Cms::ProcessHelper

  def script_state_view(name, options = {})
    options[:proc] = Sys::Process.where(name: name).first_or_initialize
    render :partial => 'cms/admin/_partial/processes/view', :locals => options
  end
end
