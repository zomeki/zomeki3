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
    
    criteria = params.deep_dup
    criteria[:sort_key] = :id if criteria[:sort_key] == 'public_uri'

    if Core.user.has_auth?(:manager) && criteria[:replace]
      if criteria[:replace_word].present?
        Cms::SiteSearchService.new(Core.site, Core.user, Core.concept).replace(criteria)
        flash.now[:notice] = '置換処理が完了しました。置換内容を公開画面へ反映するには再構築を実行してください。'
      else
        flash.now[:notice] = '置換する文字列を指定してください。'
      end
    end

    @results = Cms::SiteSearchService.new(Core.site, Core.user, Core.concept).search(criteria)
    @results.each do |result|
      result[:title], result[:anchor] = display_title(result[:model], result[:content])
      result[:items] = display_items(result[:items], result[:model], result[:content])
    end

    @count = @results.map { |result| result[:count] }.sum
  end

  private

  def display_title(model, content)
    case model.to_s
    when 'GpArticle::Doc'
      ["記事：#{content.name}", "result_docs#{content.id}"]
    when 'Cms::Node'
      ['固定ページ', "result_pages"]
    when 'Cms::Piece'
      ['ピース', "result_pieces"]
    when 'Cms::Layout'
      ['レイアウト', "result_layouts"]
    when 'Cms::DataText'
      ['テキスト', "result_data_texts"]
    when 'Cms::DataFile'
      ['ファイル', "result_data_files"]
    end
  end

  def display_items(results, model, content)
    items = results.map do |item|
      {
        id: item.id,
        title: item.title,
        state: item.state,
        state_text: item.state_text,
        concept: content ? content.concept : item.concept,
        admin_uri: item.admin_uri,
        public_uri: item.respond_to?(:public_full_uri) && model.to_s != 'Cms::Piece' ? item.public_full_uri : nil,
        created_at: item.created_at,
        updated_at: item.created_at
      }
    end
    if params[:sort_key] == 'public_uri'
      items.sort_by! {|i| [i[:public_uri], i[:id]] }
      items.reverse! if params[:sort_order] == 'desc'
    end
    return items
  end
end
