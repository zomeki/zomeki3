class GpCategory::Admin::TemplateModulesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    @content = GpCategory::Content::CategoryType.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
    @item = @content.template_modules.find(params[:id]) if params[:id].present?
  end

  def index
    @items = @content.template_modules.paginate(page: params[:page], per_page: 50)
    _index @items
  end

  def show
  end

  def new
    @item = @content.template_modules.build
  end

  def create
    @item = @content.template_modules.build(template_module_params)
    _create @item
  end

  def edit
  end

  def update
    @item.attributes = template_module_params
    _update @item
  end

  def destroy
    _destroy @item
  end

  private

  def template_module_params
    params.require(:item).permit(
      :doc_style, :module_type, :module_type_feature, :name, :num_docs, :title,
      :wrapper_tag, :upper_text, :lower_text
    )
  end
end
