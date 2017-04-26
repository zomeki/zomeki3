class AdBanner::Public::Api::Piece::BannersController < Cms::Controller::Public::Api
  def pre_dispatch
    return http_error(405) unless request.get?
    return http_error(404) unless params[:version] == '20150401'
  end

  def index
    piece = AdBanner::Piece::Banner.where(id: params[:piece_id]).first
    return render(json: {}) unless piece && piece.content.public_node

    banners = if piece.groups.empty?
                piece.banners.published
              else
                if piece.group
                  piece.group.banners.published
                else
                  piece.banners.published.select{|b| b.group.nil? }
                end
              end

    banners = case piece.sort.last
              when 'ordered'
                banners.sort{|a, b| a.sort_no <=> b.sort_no }
              when 'random'
                banners.shuffle
              else
                banners
              end

    result = {}
    result[:upper_text] = piece.upper_text.presence
    result[:lower_text] = piece.lower_text.presence
    result[:banners] = banners.map do |banner|
                           url = piece.content.click_count_related? ? banner.link_uri : banner.url
                           {alt_text: banner.alt_text, title: banner.title, target: banner.target,
                            url: url, image_url: banner.image_uri}
                         end

    render json: result
  end
end
