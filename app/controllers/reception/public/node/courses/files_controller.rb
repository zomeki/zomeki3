class Reception::Public::Node::Courses::FilesController < Cms::Controller::Public::Base
  skip_after_action :render_public_layout

  def pre_dispatch
    @node = Page.current_node
    @content = Reception::Content::Course.find(@node.content_id)
    @course = @content.courses.find_by!(name: params[:name])
  end

  def content
    params[:file] = File.basename(params[:path])
    params[:type] = :thumb if params[:path] =~ /(\/|^)thumb\//

    file = @course.files.find_by!(name: "#{params[:file]}.#{params[:format]}")
    send_file file.upload_path(type: params[:type]), filename: file.name
  end
end
