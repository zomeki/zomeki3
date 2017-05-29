class Sys::Admin::KanaDictionariesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  include Sys::Controller::Scaffold::Publication

  def pre_dispatch
    return error_auth unless Core.user.root?
  end

  def index
    return test if params[:do] == 'test'
    return make_dictionary if params[:do] == 'make_dictionary'

    @items = Cms::KanaDictionary.where(site_id: nil)
                                .order(:id)
                                .paginate(page: params[:page], per_page: params[:limit])
    _index @items
  end

  def show
    @item = Cms::KanaDictionary.find(params[:id])
    return error_auth unless @item.readable?

    _show @item
  end

  def new
    @item = Cms::KanaDictionary.new(
      :body => "" +
        "# コメント ... 先頭に「#」\n" +
        "# 辞書には登録されません。\n\n" +
        "# 日本語例 ... 「漢字, カタカナ」\n" +
        "文字, モジ\n" +
        "単語, タンゴ\n\n" +
        "# 英字例 ... 「英字, カタカナ」\n" +
        "CMS, シーエムエス\n"
    )
  end

  def create
    return test if params[:do] == 'test'

    @item = Cms::KanaDictionary.new(kana_dictionary_params)
    _create @item
  end

  def update
    @item = Cms::KanaDictionary.find(params[:id])
    @item.attributes = kana_dictionary_params
    _update @item
  end

  def destroy
    @item = Cms::KanaDictionary.find(params[:id])
    _destroy @item
  end

  def make
    makers = [Cms::KanaDictionary::Maker.new]
    makers += Cms::Site.order(:id).map { |site| Cms::KanaDictionary::Maker.new(site_id: site.id) }
    makers.each(&:make_dic)

    errors = makers.map(&:errors).flatten
    flash[:notice] = if errors.blank?
                       '辞書を更新しました。'
                     else
                       flash[:notice] = errors.join('<br />')
                     end

    redirect_to sys_kana_dictionaries_url
  end

  private

  def kana_dictionary_params
    params.require(:item).permit(:body, :name, :creator_attributes => [:id, :group_id, :user_id])
  end
end
