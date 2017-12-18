class Cms::Admin::NodesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    return redirect_to(cms_nodes_path(0)) if params[:reset]

    id      = params[:parent] == '0' ? Core.site.node_id : params[:parent]
    @parent = Cms::Node.find(id)
  end

  def index
    @dirs = Cms::Node.where(site_id: Core.site.id, parent_id: @parent.id, directory: 1)
                     .order('sitemap_sort_no IS NULL, sitemap_sort_no, name')
                     .preload(:site, :parent)

    @pages = Cms::Node.where(site_id: Core.site.id, parent_id: @parent.id, directory: [nil, 0])
                      .order('sitemap_sort_no IS NULL, sitemap_sort_no, name')
                      .preload(:site, :parent, :related_objects_for_replace)
    _index @pages
  end

  def search
    @items = Cms::Node.where(site_id: Core.site.id).search_with_params(params)
      .order('parent_id, sitemap_sort_no IS NULL, sitemap_sort_no, name')
      .paginate(page: params[:page], per_page: params[:limit])

    @skip_navi = true
    render :action => :search
  end

  def show
    @item = Cms::Node.find(params[:id])
    return error_auth unless @item.readable?

    _show @item
  end

  def new
    @item = Cms::Node.new(
      #:concept_id => @parent.inherited_concept(:id),
      :concept_id => Core.concept(:id),
      :site_id    => Core.site.id,
      :state      => 'public',
      :parent_id  => @parent.id,
      :route_id   => @parent.id,
      :layout_id  => @parent.layout_id
    )

    @contents = content_options(false)
    @models   = model_options(false)
  end

  def create
    @item = Cms::Node.new(node_params)
    @item.site_id      = Core.site.id
    #@item.parent_id    = @parent.id
    @item.state        = 'closed'
    @item.published_at = Core.now
    @item.name         = "tmp" # for validation
    @item.title        = @item.content_model_name.to_s.gsub(/.*\//, '')

    @contents = content_options(false)
    @models   = model_options(false)

    _create(@item) do
      @item.name = nil # for validation
      @item.save(:validate => false)
      respond_to do |format|
        format.html { return redirect_to(@item.admin_uri) }
      end
    end
  end

  def update
    exit
  end

  def destroy
    exit
  end

  def content_options(rendering = true)
    contents = []

    concept_id = params[:concept_id]
    concept_id = @item.concept_id if @item && @item.concept_id
    concept_id ||= Core.concept.id
    if concept = Cms::Concept.find_by(id: concept_id)
      concept.ancestors.each do |c|
        contents += Cms::Content.where(concept_id: c.id).order("sort_no IS NULL, sort_no, name, id").to_a
      end
    end

    @options  = []
    @options << [Cms::Lib::Modules.module_name(:cms), ""]
    @options += contents.collect do |c|
      concept_name = c.concept ? "#{c.concept.name} : " : nil
      ["#{concept_name}#{c.name}", c.id]
    end
    return @options unless rendering

    concept_name = concept ? "#{concept.name}:" : nil
    @options.unshift ["// 一覧を更新しました（#{concept_name}#{contents.size + 1}件）", ""]

    respond_to do |format|
      format.html { render :layout => false }
    end
  end

  def model_options(rendering = true)
    content_id = params[:content_id]
    content_id = @item.content.id if @item && @item.content

    model = 'cms'
    if content = Cms::Content.find_by(id: content_id)
      model = content.model
    end
    models  = Cms::Lib::Modules.directories(model)
    models += Cms::Lib::Modules.pages(model)

    @options  = []
    @options += models
    return models unless rendering

    content_name = content ? content.name : Cms::Lib::Modules.module_name(:cms)
    @options.unshift ["// 一覧を更新しました（#{content_name}:#{models.size}件）", '']

    respond_to do |format|
      format.html { render :layout => false }
    end
  end

  private

  def node_params
    params.require(:item).permit(
      :concept_id, :content_id, :layout_id, :model, :parent_id, :route_id,
      :sitemap_sort_no, :sitemap_state, :creator_attributes => [:id, :group_id, :user_id]
    )
  end
end
