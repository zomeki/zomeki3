class Rank::Public::Node::ThisWeeksController < Cms::Controller::Public::Base
  def pre_dispatch
    @node = Page.current_node
    @content = Rank::Content::Rank.find_by(id: Page.current_node.content.id)
    return http_error(404) unless @content
  end

  def index
    @ranks = Rank::TotalsFinder.new(@content.ranks)
                               .search(@content, 'this_weeks', 'pageviews')
                               .paginate(page: params[:page], per_page: 20)
    return http_error(404) if @ranks.current_page > @ranks.total_pages
  end
end
