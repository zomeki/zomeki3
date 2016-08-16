# encoding: utf-8
require 'nkf'
require 'csv'
class Sys::Admin::OperationLogsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  
  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
    
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end
  
  def index
    @item = Sys::OperationLog.new
    
    @item_type_options = ["all", "article", "directory", "page", "piece"]
    @action_type_options = [["作成","create"], ["更新","update"], ["承認","recognize"], ["削除","destroy"], ["公開","publish"], ["非公開","close"], ["ログイン","login"], ["ログアウト","logout"]]
   
    items = Core.site.operation_logs.search_with_params(params).order(id: :desc)
    return destroy_items(items) if params[:destroy].present?
    return export_csv(items) if params[:csv].present?

    @items = items.paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end
  
  def show
    @item = Core.site.operation_logs.find(params[:id])

    _show @item
  end
  
  def new; http_error(404); end
  def edit; http_error(404); end
  def create; http_error(404); end
  def update; http_error(404); end
  def destroy; http_error(404); end
  
protected
  
  def destroy_items(items)
    num = items.delete_all

    flash[:notice] = "削除処理が完了しました。##{num}件"
    redirect_to url_for(:action => :index)
  end

  def export_csv(items)
    csv = CSV.generate do |csv|
      fields = ["ログID", :created_at, :user_id, :user_name, :ipaddr, :uri, :action, :item_model, :item_id, :item_name]
      csv << fields.map {|c| c.is_a?(Symbol) ? Sys::OperationLog.human_attribute_name(c) : c }

      items.each do |item|
        row = []
        row << item.id
        row << item.created_at.strftime("%Y-%m-%d %H:%M:%S")
        row << item.user_id
        row << item.user_name
        row << item.ipaddr
        row << item.uri
        row << item.action_text
        row << item.item_model
        row << item.item_id
        row << item.item_name
        csv << row
      end
    end

    csv = NKF.nkf('-s', csv)
    send_data(csv, :type => 'text/csv', :filename => "sys_operation_logs_#{Time.now.to_i}.csv")
  end
end
