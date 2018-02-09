class AdBanner::Public::Api::Piece::ClicksController < Cms::Controller::Public::Api
  def pre_dispatch
    return http_error(405) unless request.get?

    @piece = AdBanner::Piece::Banner.find(params[:piece_id])
    return render(json: {}) unless @piece.content.public_node
  end

  def index
    @banner = @piece.content.banners.find_by(token: params[:token])
    @banner.clicks.create(referer: request.referer, remote_addr: request.remote_ip, user_agent: request.user_agent)
    render json: { result: 'OK' }
  end
end
