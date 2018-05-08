class Cms::Admin::Tool::SearchController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:creator)
    return redirect_to(action: :index) if params[:reset]

    if params[:target].nil?
      params[:check_all] = 'check_all'
      params[:target] = ['gp_article', 'node_page', 'piece', 'layout', 'data_text', 'data_file']
    end
  end

  def index
    @results = []
    return if params[:keyword].blank?

    if Core.user.has_auth?(:manager) && params[:replace]
      if params[:replace_word].present?
        Cms::SiteSearchService.new(Core.site, Core.user, Core.concept).replace(params)
        flash.now[:notice] = '置換処理が完了しました。置換内容を公開画面へ反映するには再構築を実行してください。'
      else
        flash.now[:notice] = '置換する文字列を指定してください。'
      end
    end

    @results = Cms::SiteSearchService.new(Core.site, Core.user, Core.concept).search(params)
    @results.each do |result|
      result[:title] = display_title(result[:model], result[:content])
      result[:items] = display_items(result[:items], result[:content])
    end

    @count = @results.map { |result| result[:count] }.sum
  end

  private

  def display_title(model, content)
    case model.to_s
    when 'GpArticle::Doc'
      "記事：#{content.name}"
    when 'Cms::Node'
      '固定ページ'
    when 'Cms::Piece'
      'ピース'
    when 'Cms::Layout'
      'レイアウト'
    when 'Cms::DataText'
      'テキスト'
    when 'Cms::DataFile'
      'ファイル'
    end
  end

  def display_items(items, content)
    items.map do |item|
      {
        id: item.id,
        title: item.title,
        state: item.state,
        state_text: item.state_text,
        concept: content ? content.concept : item.concept,
        admin_uri: item.admin_uri,
        public_uri: item.respond_to?(:public_full_uri) ? item.public_full_uri : nil
      }
    end
  end
end
