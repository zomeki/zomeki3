class GpArticle::Admin::CommentsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    @content = GpArticle::Content::Doc.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
    return redirect_to(action: :index) if params[:reset_criteria]

    @item = GpArticle::Comment.content_and_criteria(@content, {}).find(params[:id]) if params[:id].present?
  end

  def index
    @items = GpArticle::Comment.content_and_criteria(@content, params[:criteria] || {})
                               .order(posted_at: :desc)
                               .paginate(page: params[:page], per_page: 30)
  end

  def show
  end

  def edit
  end

  def update
    @item = GpArticle::Comment.content_and_criteria(@content, {}).find(params[:id])
    @item.attributes = comment_params
    _update @item
  end

  def destroy
    _destroy @item
  end

  private

  def comment_params
    params.require(:item).permit(:state, :author_name, :author_email, :author_url, :body, :posted_at)
  end
end
