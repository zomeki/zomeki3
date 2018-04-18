class Sys::Controller::Public::Base < ApplicationController
  include Jpmobile::ViewSelector

  layout false
  prepend_around_action :freeze_preview_time
  prepend_before_action :set_page_variables
  before_action :pre_dispatch
  rescue_from ActiveRecord::RecordNotFound, with: -> { http_error(404) }

  def pre_dispatch
    ## each processes before dispatch
  end

  private

  def set_page_variables
    Page.mobile = true if request.mobile?
    Page.smart_phone = true if request.smart_phone?
  end

  def freeze_preview_time
    if Core.mode == 'preview' && Page.preview_at
      Timecop.freeze(Page.preview_at) { yield }
    else
      yield
    end
  end
end
