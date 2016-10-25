class Survey::Admin::QuestionsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    @content = Survey::Content::Form.find(params[:content])
    @form = @content.forms.find(params[:form_id])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
  end

  def index
    @items = @form.questions.paginate(page: params[:page], per_page: 30)
    _index @items
  end

  def show
    @item = @form.questions.find(params[:id])
    _show @item
  end

  def new
    @item = @form.questions.build
  end

  def create
    @item = @form.questions.build(question_params)
    _create @item
  end

  def update
    @item = @form.questions.find(params[:id])
    @item.attributes = question_params
    _update @item
  end

  def destroy
    @item = @form.questions.find(params[:id])
    _destroy @item
  end

  private

  def question_params
    params.require(:item).permit(
      :description, :form_options, :form_text_max_length, :form_type, :required, :sort_no,
      :state, :style_attribute, :title
    )
  end
end
