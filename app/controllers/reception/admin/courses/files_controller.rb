class Reception::Admin::Courses::FilesController < Cms::Controller::Admin::Base
  def pre_dispatch
    @content = Reception::Content::Course.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)
    @course = @content.courses.find(params[:course_id])
  end

  def content
    params[:file] = File.basename(params[:path])
    params[:type] = :thumb if params[:path] =~ /(\/|^)thumb\//

    file = @course.files.find_by!(name: "#{params[:file]}.#{params[:format]}")
    send_file file.upload_path(type: params[:type]), filename: file.name
  end
end
