class Sys::Admin::ProcessesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)

    if params[:id]
      @process_name = params[:id].to_s.gsub(/@/, '/')
      return http_error(500) if @process_name =~ /[^\w_#\/]/
    end
  end

  def index
    @items = Sys::Process::RUNNABLE_PROCESSES.map do |title, name|
      Sys::Process.where(name: name, site_id: Core.site.id).order(id: :desc).first_or_initialize
    end
  end

  def show
    @item = Sys::Process.where(name: @process_name, site_id: Core.site.id).order(id: :desc).first_or_initialize

    case params[:do]
    when 'start_process'
      start_process(@item)
      redirect_to action: :show
    when 'stop_process'
      stop_process(@item)
      redirect_to action: :show
    end
  end

  private

  def start_process(item)
    if item.state == "running"
      flash[:notice] = "プロセスが既に実行されています。"
    else
      begin
        ::Script.run_from_web(item.name, site_id: Core.site.id)
        flash[:notice] = "プロセスを開始しました。"
      rescue => e
        flash[:notice] = e.to_s
      end
    end
  end

  def stop_process(item)
    if !item || item.state != "running"
      flash[:notice] = "プロセスは実行されていません。"
    else
      item.update_attributes(interrupt: "stop")
      flash[:notice] = "プロセスの停止を要求しました。"
    end
  end
end
