class Cms::Admin::Piece::BaseController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  before_action :pre_dispatch_piece

  def pre_dispatch_piece
    return error_auth unless Core.user.has_auth?(:designer)

    @item = model.find(params[:id]) if params[:id].present?
  end

  def model
    return @model_class if @model_class
    mclass = self.class.to_s.gsub(/^(\w+)::Admin/, '\1').gsub(/Controller$/, '').singularize
    @model_class = mclass.constantize
  rescue
    @model_class = Cms::Piece
  end

  def index
    redirect_to cms_pieces_path
  end

  def show
    return error_auth unless @item.readable?
    _show @item
  end

  def update
    @item.attributes = base_params
    @item.updated_at = Time.now

    _update @item do
      Core.set_concept(session, @item.concept_id)
      respond_to do |format|
        format.html { return redirect_to(cms_pieces_path) }
      end
    end
  end

  def destroy
    _destroy @item do
      respond_to do |format|
        format.html { return redirect_to(cms_pieces_path) }
      end
    end
  end

  def publish(item)
    item.state = 'public'
    _update item
  end

  def close(item)
    item.state = 'closed'
    _update item
  end

  def duplicate(item)
    if dupe_item = item.duplicate
      flash[:notice] = '複製処理が完了しました。'
      respond_to do |format|
        format.html { redirect_to cms_pieces_path }
        format.xml  { head :ok }
      end
    else
      flash[:notice] = "複製処理に失敗しました。"
      respond_to do |format|
        format.html { redirect_to url_for(action: :show) }
        format.xml  { render xml: item.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def base_params
    nested = {creator_attributes: base_params_item_in_creator,
              in_settings: base_params_item_in_settings}
    params.require(:item).permit(*base_params_item, nested)
  end

  def base_params_item
    [:concept_id, :name, :state, :title, :view_title]
  end

  def base_params_item_in_creator
    [:id, :group_id, :user_id]
  end

  def base_params_item_in_settings
    []
  end
end
