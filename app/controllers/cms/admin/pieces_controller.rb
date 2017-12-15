class Cms::Admin::PiecesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
  end

  def index
    @items = Cms::Piece.readable.order(:name, :id)
                       .paginate(page: params[:page], per_page: params[:limit])
                       .preload(:related_objects_for_replace)
    _index @items
  end

  def show
    if params[:do] == 'preview'
      preview
    else
      exit
    end
  end

  def preview
    @item = Cms::Piece.find(params[:id])
    return error_auth unless @item.readable?

    render :preview
  end

  def new
    @item = Cms::Piece.new(
      :concept_id => Core.concept(:id),
      :state      => 'public'
    )

    @contents = content_options(false)
    @models   = model_options(false)
  end

  def create
    @item = Cms::Piece.new(piece_params)
    @item.site_id = Core.site.id

    @contents = content_options(false)
    @models   = model_options(false)

    _create @item do
      Core.set_concept(session, @item.concept_id)
      respond_to do |format|
        format.html { return redirect_to(@item.admin_uri) }
      end
    end
  end

  def update
    exit
  end

  def destroy
    @item = Cms::Piece.find(params[:id])
    _destroy @item
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
    models = Cms::Lib::Modules.pieces(model)

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

  def piece_params
    params.require(:item).permit(
      :concept_id, :content_id, :model, :name, :state, :title, :view_title,
      :creator_attributes => [:id, :group_id, :user_id]
    )
  end
end
