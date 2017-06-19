class AdBanner::BannersScript < Cms::Script::Publication
  def publish
    banners = @node.content.banners
    banners.each do |banner|
      ::Script.progress(banner) do
        banner.publish_or_close_images
      end
    end
  end
end
