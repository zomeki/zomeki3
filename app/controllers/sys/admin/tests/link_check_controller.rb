class Sys::Admin::Tests::LinkCheckController < Cms::Controller::Admin::Base
  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
  end
  
  def index
    return if request.get?

    @links = params.dig(:item, :body).to_s.split(/\r\n|\n|\r/m).select(&:present?).map do |url|
      link = { url: url }
      link.merge(Util::LinkChecker.check_url(url))
    end
  end
end
