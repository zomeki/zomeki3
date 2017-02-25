class Cms::Admin::Tool::RebuildController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  
  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
  end
  
  def index
    content_models = [
      'GpArticle::Doc',
      'GpCategory::CategoryType',
      'Organization::Group',
      'AdBanner::Banner',
      'Map::Marker',
      'GpCalendar::Event',
      'Tag::Tag',
      'Rank::Rank',
      'Gnav::MenuItem',
      'Feed::Feed',
      'BizCalendar::Place'
    ]
    @contents = Cms::Content.distinct.joins(:nodes)
                            .where(site_id: Core.site.id, model: content_models)
                            .where(Cms::Node.arel_table[:state].eq('public'))
                            .order(:name)
    @nodes = Cms::Node.public_state
                      .where(site_id: Core.site.id, model: ['Cms::Page', 'Cms::Sitemap'])
                      .preload(:site, parent: { parent: { parent: nil } })
                      .sort_by { |n| n.public_uri }
  end

  def rebuild_contents
    contents = Cms::Content.where(id: params[:target_content_ids])
    return redirect_to(url_for(action: 'index'), alert: '対象を選択してください。') if contents.empty?

    Cms::RebuildJob.perform_later(site_id: Core.site.id, target_content_ids: contents.map(&:id))

    redirect_to url_for(action: 'index'), notice: '再構築を開始しました。完了までに時間がかかる場合があります。'
  end

  def rebuild_nodes
    nodes = Cms::Node.where(id: params[:target_node_ids])
    return redirect_to(url_for(action: 'index'), alert: '対象を選択してください。') if nodes.empty?

    Cms::RebuildJob.perform_later(site_id: Core.site.id, target_node_ids: nodes.map(&:id))

    redirect_to url_for(action: 'index'), notice: '再構築を開始しました。完了までに時間がかかる場合があります。'
  end

  def rebuild_params
    params.except(:concept).permit(:target_node_ids, :target_content_ids)
  end
end
