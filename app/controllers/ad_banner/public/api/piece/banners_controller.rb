class AdBanner::Public::Api::Piece::BannersController < Cms::Controller::Public::Api
  def pre_dispatch
    return http_error(405) unless request.get?
    return http_error(404) unless params[:version] == '20150401'

    @piece = AdBanner::Piece::Banner.where(id: params[:piece_id]).first
    return render(json: {}) unless @piece && @piece.content.public_node
  end

  def index
    banners = if @piece.groups.empty?
                @piece.banners.published
              else
                if @piece.group
                  @piece.group.banners.published
                else
                  @piece.banners.published.select{|b| b.group.nil? }
                end
              end

    banners = case @piece.sort.last
              when 'ordered'
                banners.sort{|a, b| a.sort_no <=> b.sort_no }
              when 'random'
                banners.shuffle
              else
                banners
              end

    result = {}
    result[:upper_text] = @piece.upper_text.presence
    result[:lower_text] = @piece.lower_text.presence
    result[:banners] = banners.map { |banner| banner_to_hash(banner) }

    render json: result
  end

  private

  def banner_to_hash(banner)
    url = if request.mobile? && @piece.content.click_count_related?
            banner.link_uri
          else
            request.smart_phone? && banner.sp_url.presence || banner.url
          end
    image_url = if @piece.content.image_display == 'embed' && File.exist?(banner.image_path) && !request.mobile?
                  ApplicationController.helpers.data_uri(File.read(banner.image_path), mime_type: banner.mime_type)
                else
                  banner.image_uri
                end
    {
      id: banner.id,
      token: banner.token,
      url: url,
      image_url: image_url,
      alt_text: banner.alt_text,
      title: banner.title,
      target: banner.target
    }
  end
end
