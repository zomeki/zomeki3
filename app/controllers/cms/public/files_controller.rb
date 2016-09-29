class Cms::Public::FilesController < ApplicationController
  def down
    paths = params[:path].to_s.split('/')
    return http_error(404) if paths.size != 2 && paths.size != 3

    id    = paths[0]
    name  = "#{paths.last}.#{params[:format]}"
    type  = paths.size == 3 ? paths[1] : nil
    return http_error(404) if id !~ /^[0-9]+$/

    item = Cms::DataFile.public_state.where(id: id.chop, name: name).first
    return http_error(404) unless item

    path = item.public_path
    path = ::File.dirname(path) + "/#{type}/#{name}" if type
    return http_error(404) unless FileTest.exist?(path)

    if type
      return send_file(path, type: item.mime_type, filename: item.name)
    end

    if img = item.mobile_image(request.mobile, path: item.public_path)
      return send_data(img.to_blob, type: item.mime_type, filename: item.name, disposition: 'inline')
    end

    return send_file(path, type: item.mime_type, filename: item.name, disposition: 'inline')
  end
end
