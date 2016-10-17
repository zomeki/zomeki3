class AdBanner::Script::BannersController < Cms::Controller::Script::Publication
  def publish
    render plain: 'OK'
  end
end
