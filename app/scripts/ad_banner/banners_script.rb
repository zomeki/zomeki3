class AdBanner::BannersScript < Cms::Script::Publication
  def publish
    banners = @node.content.banners
    banners.each do |banner|
      ::Script.progress(banner) do
        if banner.published?
          banner.publish_images
        else
          banner.close_images
        end
      end
    end
  end
end
