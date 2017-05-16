class Sys::Admin::SettingsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.root?
    return redirect_to(action: :index) if params[:reset]
  end

  def index
    @items = Sys::Setting.configs.values.map { |config| Sys::Setting.where(name: config[:id]).first }
    _index @items
  end

  def show
    @item = Sys::Setting.where(name: params[:id]).first_or_initialize
    _show @item
  end

  def update
    @item = Sys::Setting.where(name: params[:id]).first_or_initialize
    @item.value = params[:item][:value]

    if @item.name =~ /^(common_ssl|maintenance_mode)$/
      extra_values = @item.extra_values

      case @item.name
      when 'common_ssl'
        extra_values[:common_ssl_uri] = params[:common_ssl_uri]
      when 'maintenance_mode'
        extra_values[:maintenance_start_at] = params[:maintenance_start_at]
        extra_values[:maintenance_end_at] = params[:maintenance_end_at]
      end

      @item.extra_values = extra_values
    end
    _update(@item, location: edit_sys_setting_path(id: params[:id]))
  end
end
