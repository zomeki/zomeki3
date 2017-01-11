class GpArticle::Admin::Docs::FilesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    @content = GpArticle::Content::Doc.find(params[:content])
    @doc = @content.all_docs.find(params[:doc_id])
  end

  def content
    params[:name] = File.basename(params[:path])
    params[:type] = :thumb if params[:path] =~ /(\/|^)thumb\//

    file = @doc.files.find_by!(name: "#{params[:name]}.#{params[:format]}")
    send_file file.upload_path(type: params[:type]), filename: file.name
  end
end
