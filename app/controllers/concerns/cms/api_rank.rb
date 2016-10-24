module Cms::ApiRank
  extend ActiveSupport::Concern

  include Rank::Controller::Rank

  included do
  end

  def rank(path:, version:)
    case path.shift
    when 'piece_ranks'; rank_piece_ranks(path: path, version: version)
    else render_404
    end
  end

  def rank_piece_ranks(path:, version:)
    return render_404 if path.present?
    return render_405 unless request.get?
    return render_404 unless version == '20150401'

    piece = Rank::Piece::Rank.where(id: params[:piece_id]).first
    return render(json: {}) unless piece

    current_item = rank_current_item(params[:current_item_class], params[:current_item_id])
    return render(json: {}) unless current_item

    term = piece.ranking_term
    target = piece.ranking_target
    ranks = rank_datas(piece.content, term, target, piece.display_count, piece.category_option, nil, nil, nil, current_item)

    result = {}
    result[:ranks] = ranks.map do |rank|
                         {title: rank.page_title,
                            url: "#{request.scheme}://#{rank.hostname}#{rank.page_path}",
                          count: piece.show_count == 0 ? nil : rank.accesses}
                       end
    result[:more] = if (body = piece.more_link_body).present? && (url = piece.more_link_url).present?
                      {body: body, url: url}
                    end

    render json: result
  end

  private

  def rank_current_item(current_item_class, current_item_id)
    if current_item_class.in?(%w(GpCategory::CategoryType GpCategory::Category))
      current_item_class.constantize.find_by(id: current_item_id)
    else
      nil
    end
  end
end
