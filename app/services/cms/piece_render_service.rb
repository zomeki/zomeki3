class Cms::PieceRenderService < ApplicationService
  def initialize(piece)
    @piece = piece
  end

  def render(request, params)
    mnames = @piece.model.underscore.pluralize.split('/')
    controller = "#{mnames[0]}/public/piece/#{mnames[1]}"
    data = Sys::Lib::Controller.render(controller, 'index', request: request, params: params)

    if data =~ /^<html/ && Rails.env.production?
      # component error
    else
      piece_container_html(@piece, data)
    end
  rescue => e
    error_log e
  end

  private

  def piece_container_html(piece, body)
    return '' if body.blank?

    title = piece.view_title
    return body if piece.model == 'Cms::Free' && title.blank?

    html  = %Q(<div#{piece.css_attributes}>\n)
    html += %Q(<div class="pieceContainer">\n)
    html += %Q(<div class="pieceHeader"><h2>#{title}</h2></div>\n) if title.present?
    html += %Q(<div class="pieceBody">#{body}</div>\n)
    html += %Q(</div>\n)
    html += %Q(<!-- end .piece --></div>\n)
    html.html_safe
  end
end
