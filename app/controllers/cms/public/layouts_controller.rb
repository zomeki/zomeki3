# encoding: utf-8
class Cms::Public::LayoutsController < ApplicationController
  def index
    name = "#{params[:file]}.#{params[:format]}"
    layout_id = params[:id].to_s.gsub(/.$/, '').to_i
    
    @item = Cms::Layout.find_by(site_id: Page.site.id, id: layout_id)
    return http_error(404) unless @item
    
    body = nil
    if name == 'style.css'
      body = @item.stylesheet
    elsif name == 'mobile.css'
      body = @item.mobile_stylesheet
    elsif name == 'smart_phone.css'
      body = @item.smart_phone_stylesheet
    end
    
    send_data body, :type => 'text/css', :filename => name, :disposition => 'inline'
  end
end
