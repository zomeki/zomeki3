class Sys::Admin::PluginsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.root?
  end

  def index
    return version_options if params[:version_options]
    return title_options if params[:title_options]

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
      update_plugins
    end
  end

  def update
    @item = Sys::Plugin.find(params[:id])
    @item.attributes = plugin_params
    _create @item do
      update_plugins
    end
  end

  def destroy
    @item = Sys::Plugin.find(params[:id])
    _destroy @item do
      update_plugins
    end
  end

  def restart
    if bundle_install
      restart_application
      flash[:notice] = "アプリケーションを再起動しました。"
    else
      flash[:notice] = "アプリケーションの再起動に失敗しました。"
    end
    redirect_to url_for(action: :index)
  end

  private

  def version_options
    opts = Sys::Plugin.version_options(params[:name])
    render plain: view_context.options_for_select([['','']] + opts), layout: false
  end

  def title_options
    title = Sys::Plugin.title_options(params[:name])
    render plain: title, layout: false
  end

  def plugin_params
    params.require(:item).permit(:name, :title, :version, :state, :note, :use_as_content)
  end

  def update_plugins
    Rails::Generators.invoke('sys:plugins:config', ['--force'])
    flash[:notice] = "プラグインリストを更新しました。プラグインの利用にはアプリケーションの再起動が必要です。"
  end

  def bundle_install
    # remove bundler/setup and gem path
    tmp = ENV.to_h.slice('RUBYOPT', 'GEM_PATH')
    tmp.each { |key, _| ENV[key] = nil }

    require 'open3'
    stdout, stderr, status = Open3.capture3("bundle install")
    status.success?
  ensure
    tmp.each { |key, val| ENV[key] = val if val }
  end

  def restart_application
    `bundle exec rake delayed_job:restart RAILS_ENV=#{Rails.env}`
    `bundle exec rake unicorn:restart RAILS_ENV=#{Rails.env}`
  end
end
