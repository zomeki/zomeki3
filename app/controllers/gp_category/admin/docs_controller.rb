class GpCategory::Admin::DocsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  before_action :find_doc, :only => [ :show, :edit, :update ]

  def pre_dispatch
    @content = GpCategory::Content::CategoryType.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)
    @category_type = @content.category_types.find(params[:category_type_id])
    @category = @category_type.categories.find(params[:category_id])
    return redirect_to(action: :index) if params[:reset_criteria]
  end

  def index
    @items = find_docs.paginate(page: params[:page], per_page: 30)
                      .preload(:categorizations, creator: [:user, :group])
    _index @items
  end

  def show
    _show @item
  end

  def edit
    _show @item
  end

  def update
    if (categorization = @item.categorizations.find_by(category_id: @category.id))
      categorization.sort_no = params[:sort_no]
      if categorization.save
        redirect_to({:action => :index}, notice: '更新処理が完了しました。')
      else
        flash.now[:alert] = '更新処理に失敗しました。'
        render :action => :edit
      end
    else
      redirect_to({:action => :show}, alert: '更新処理に失敗しました。')
    end
  end

  private

  def find_docs
    criteria = params[:criteria] || {}
    GpArticle::Doc.categorized_into(@category.id).content_and_criteria(nil, criteria)
  end

  def find_doc
    @item = find_docs.find(params[:id])
  end
end
