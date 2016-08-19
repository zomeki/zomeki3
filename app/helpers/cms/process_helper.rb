module Cms::ProcessHelper

  def script_state_view(name, options = {})
    options[:proc] = Sys::Process.where(name: name).first_or_initialize
    render 'cms/admin/_partial/processes/view', options
  end
end
