# encoding: utf-8
class GpCategory::Admin::DocsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  before_action :find_doc, :only => [ :show, :edit, :update ]

  def pre_dispatch
    @content = GpCategory::Content::CategoryType.find(params[:content])
    @category_type = @content.category_types.find(params[:category_type_id])
    @category = @category_type.categories.find(params[:category_id])
    return redirect_to(request.env['PATH_INFO']) if params[:reset_criteria]
  end

  def index
    _index (@items = find_docs.paginate(page: params[:page], per_page: 30))
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
    criteria[:category_id] = @category.id
    GpArticle::Doc.content_and_criteria(nil, criteria)
  end

  def find_doc
    @item = find_docs.find(params[:id])
  end
end
