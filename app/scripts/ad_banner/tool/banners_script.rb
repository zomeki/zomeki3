class AdBanner::Tool::BannersScript < Cms::Script::Base
  def rebuild
    content = AdBanner::Content::Banner.find(params[:content_id])
    content.banners.each do |banner|
      ::Script.progress(banner) do
        banner.publish_or_close_image
      end
    end
  end
end
