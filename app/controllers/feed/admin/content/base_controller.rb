class Feed::Admin::Content::BaseController < Cms::Admin::Content::BaseController
  def model
    Feed::Content::Feed
  end
end
