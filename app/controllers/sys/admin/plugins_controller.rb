class Sys::Admin::PluginsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.root?
  end

  def index
    return version_options if params[:version_options]

    @items = Sys::Plugin.search_with_params(params).order(:name)
                        .paginate(page: params[:page], per_page: params[:limit])
    _index @items
  end

  def show
    @item = Sys::Plugin.find(params[:id])
    _show @item
  end

  def new
    @item = Sys::Plugin.new(state: 'enabled')
  end

  def create
    @item = Sys::Plugin.new(plugin_params)
    _create @item do
      update_plugins && restart_application
    end
  end

  def update
    @item = Sys::Plugin.find(params[:id])
    @item.attributes = plugin_params
    _create @item do
      update_plugins && restart_application
    end
  end

  def destroy
    @item = Sys::Plugin.find(params[:id])
    _destroy @item do
      update_plugins && restart_application
    end
  end

  private

  def version_options
    opts = Sys::Plugin.version_options(params[:name])
    render plain: view_context.options_for_select(opts), layout: false
  end

  def plugin_params
    params.require(:item).permit(:name, :title, :version, :state, :note)
  end

  def update_plugins
    Rails::Generators.invoke('sys:plugins:config', ['--force'])

    status = bundle_install

    flash[:notice] = status ? "プラグインリストを更新しました。" : "プラグインリストの更新に失敗しました。"
    status
  end

  def bundle_install
    # prevent bundler/setup
    rubyopt = ENV['RUBYOPT']
    ENV['RUBYOPT'] = nil

    require 'open3'
    stdout, stderr, status = Open3.capture3("bundle install")
    status.success?
  ensure
    ENV['RUBYOPT'] = rubyopt if rubyopt
  end

  def restart_application
    pid_file = Rails.root.join('tmp/pids/unicorn.pid')
    `kill -USR2 \`cat #{pid_file}\`` if File.exist?(pid_file)
  end
end
