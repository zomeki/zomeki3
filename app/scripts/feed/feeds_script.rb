class Feed::FeedsScript < Cms::Script::Base
  def read
    success = 0
    error   = 0

    feeds = Feed::Feed.where(state: 'public')
    if ::Script.site
      content_ids = Feed::Content::Feed.where(site_id: ::Script.site.id).pluck(:id)
      feeds = feeds.where(content_id: content_ids)
    end

    ::Script.total feeds.size

    feeds.each do |feed|
      ::Script.current

      begin
        if feed.update_feed
          ::Script.success
          success += 1
        else
          raise "DestroyFailed : #{feed.uri}"
        end
      rescue ::Script::InterruptException => e
        raise e
      rescue => e
        ::Script.error e
        error += 1
      end
    end

    if error > 0
      puts "Finished. Success: #{success}, Error: #{error}"
    else
      puts "Finished. Success: #{success}"
    end
  end
end
