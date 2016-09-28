class Sys::Admin::ProcessesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  include Cms::Controller::Scaffold::Process

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)

    if params[:id]
      @process_name = params[:id].to_s.gsub(/@/, '/')
      return http_error(500) if @process_name =~ /[^\w_#\/]/
    end
  end

  def index
    @items = []
    Sys::Process::PROCESSE_LIST.each do |title, name|
      item = Sys::Process.find_by(name: name) || Sys::Process.new
      item.title  = title
      item.name ||= name
      @items << item
    end
  end

  def show
    #res = ::Script.run(@process_name); raise "process: #{@process_name}"

    @process = Sys::Process.find_by(name: @process_name) || Sys::Process.new(name: @process_name)
    Sys::Process::PROCESSE_LIST.each {|title, name| @process.title = title if name == @process_name }
    options = {site_id: Core.site.id}

    return send(params[:do], @process_name, options) if params[:do] =~ /^(start|stop)_process/
  end

protected

end
