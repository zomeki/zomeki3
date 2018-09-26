class Cms::Public::PiecesController < Cms::Controller::Public::Data
  def index
    piece = Cms::Piece.find(params[:id].to_s.chop)
    return http_error(404) if piece.state != 'public'

    Page.current_piece = piece
    body = Cms::PieceRenderService.new(piece).render(request, params)
    return http_error(404) if body.blank?

    if Page.ruby
      body = Cms::Lib::Navi::Kana.convert(body, Page.site.id)
    end

    render html: body.html_safe
  end
end
