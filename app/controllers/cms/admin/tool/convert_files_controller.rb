# encoding: utf-8
class Cms::Admin::Tool::ConvertFilesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
  end

  def index
    paths = params[:path].to_s.split('/')
    @site_url = paths.first || ''
    @path = paths.drop(1).join('/')
    @rel_path  = params[:path]

    @root      = "#{::Tool::Convert::SITE_BASE_DIR}/#{@site_url}"
    @full_path = "#{@root}/#{@path}"
    @base_uri  = ["#{::Tool::Convert::SITE_BASE_DIR}/", "/"]

    @item = Tool::SiteContent.new(@site_url, @full_path, :root => @root, :base_uri => @base_uri)

    if @item.file?
      @rel_path = @rel_path.sub(/\/[^\/]*$/, '')
      params[:do] = "show"
      return show
    else
      return show if params[:do] == 'show'
    end

    @dirs  = @item.child_directories
    @files = @item.child_files
  end

  def show
    render :show
  end
end
