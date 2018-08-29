class Cms::Public::CommonController < Cms::Controller::Public::Data
  protect_from_forgery except: :index

  def index
    return http_error(404) unless Page.site

    path = "#{Page.site.public_path}/_common/#{params[:path]}"
    return http_error(404) if !::File.exists?(path) || !::File.file?(path)

    send_file path
  end
end
