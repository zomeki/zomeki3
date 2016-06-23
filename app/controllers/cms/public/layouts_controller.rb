class Cms::Public::LayoutsController < ApplicationController
  def index
    item = Cms::Layout.find_by(site_id: Page.site.id, id: params[:id])
    return http_error(404) unless item

    filename = "#{params[:file]}.#{params[:format]}"
    body = case filename
           when 'style.css'
             item.stylesheet
           when 'mobile.css'
             item.mobile_stylesheet
           when 'smart_phone.css'
             item.smart_phone_stylesheet
           end

    send_data body, type: 'text/css', filename: filename, disposition: 'inline'
  end
end
