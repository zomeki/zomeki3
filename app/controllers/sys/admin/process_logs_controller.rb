require 'nkf'
require 'csv'
class Sys::Admin::ProcessLogsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
    return redirect_to(action: :index) if params[:reset]
  end

  def index
    @item = Sys::Process.new
    items = Sys::ProcessLog.search_with_params(params).order(id: :desc)
    @items = items.paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def show
    @item = Sys::ProcessLog.find(params[:id])

    _show @item
  end

  def new; http_error(404); end
  def edit; http_error(404); end
  def create; http_error(404); end
  def update; http_error(404); end
  def destroy; http_error(404); end

protected

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
