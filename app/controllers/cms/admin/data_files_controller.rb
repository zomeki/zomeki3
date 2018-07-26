class Cms::Admin::DataFilesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  include Sys::Controller::Scaffold::Publication

  keep_params :s_node_id, to: [:data_files, :data_file_nodes]

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    return redirect_to url_for(action: :index) if params[:reset]
  end

  def index
    @nodes = Cms::DataFileNode.where(concept_id: Core.concept(:id)).order(:name)

    files = Cms::DataFile.arel_table

    rel = Cms::DataFile.order(params[:s_sort] == 'updated_at' ? {updated_at: :desc, id: :asc} : {name: :asc, id: :asc})
    rel = rel.search_with_text(:name, :title, params[:s_keyword]) if params[:s_keyword].present?
    rel = rel.where(node_id: params[:s_node_id]) if params[:s_node_id].present?
    rel = unless Core.user.has_auth?(:manager) || params[:s_target] == 'current'
            rel.readable
          else
            rel = rel.where(concept_id: Core.concept.id) unless params[:s_target] == 'all'
            rel.where(site_id: Core.site.try(:id))
          end

    @items = rel.paginate(page: params[:page], per_page: params[:limit])
                .preload(:site, :node)

    _index @items
  end

  def show
    @item = Cms::DataFile.find(params[:id])
    return error_auth unless @item.readable?
    _show @item
  end

  def new
    @item = Cms::DataFile.new(
      concept_id: Core.concept(:id),
      state: 'public'
    )
  end

  def create
    @item = Cms::DataFile.new(data_file_params)
    @item.site_id = Core.site.id
    @item.state   = 'public'
    @item.image_resize = params[:image_resize]
    @item.allowed_types = Core.site.allowed_attachment_types
    _create @item do
      @item.publish if @item.state == 'public'
    end
  end

  def update
    @item = Cms::DataFile.find(params[:id])
    @item.attributes = data_file_params
    @item.node_id    = nil if @item.concept_id_changed?
    @item.image_resize = params[:image_resize]
    @item.allowed_types = Core.site.allowed_attachment_types
    old_name = @item.name_changed? ? Cms::DataFile.find(params[:id]).try(:escaped_name) : nil

    @item.skip_upload if @item.file.blank?
    _update @item do
      @item.remove_old_name_public_file(old_name) unless old_name.blank?
      @item.publish if @item.state == 'public'
    end
  end

  def destroy
    @item = Cms::DataFile.find(params[:id])
    _destroy @item
  end

  def download
    @file = Cms::DataFile.find(params[:id])
    return error_auth unless @file.readable?

    send_file @file.upload_path, type: @file.mime_type, filename: @file.name, disposition: 'inline'
  end

  private

  def data_file_params
    params.require(:item).permit(:concept_id, :node_id, :file, :name, :title, :alt_text)
  end
end
