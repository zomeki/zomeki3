class Cms::SiteSearchService < ApplicationService
  def initialize(site, user, current_concept)
    @site = site
    @user = user
    @current_concept = current_concept

    @columns = {
      Cms::Node => [:title, :body, :mobile_title, :mobile_body],
      Cms::Piece => [:name, :title, :view_title, :body],
      Cms::PieceSetting => [:value],
      Cms::Layout => [:name, :title, :head, :body, :mobile_head, :mobile_body, :smart_phone_head, :smart_phone_body],
      Cms::DataText => [:name, :title, :body],
      Cms::DataFile => [:name, :title, :alt_text],
      GpArticle::Doc => [:title, :subtitle, :summary, :body, :body_more, :mobile_title, :mobile_body,
                         :event_note, :meta_description, :meta_keywords, :remark]
    }
    @setting_names = {
      Cms::PieceSetting => ['upper_text', 'lower_text']
    }
  end

  def search(criteria)
    concepts = load_target_concepts(criteria)
    
    sort = {
        :key => (criteria[:sort_key].presence || :id).to_sym,
        :order => (criteria[:sort_order].presence || :asc).to_sym
      }

    results = []

    if criteria[:target].include?('gp_article')
      contents = load_gp_article_contents(concepts)
      contents.each do |content|
        items = search_gp_article_docs(content, criteria, sort)
        results << { model: GpArticle::Doc,
                     content: content,
                     items: items,
                     count: items.size }
      end
    end

    if criteria[:target].include?('node_page') && @user.has_auth?(:designer)
      items = search_cms_nodes(concepts, criteria, sort)
      results << { model: Cms::Node,
                   items: items,
                   count: items.size }
    end

    if criteria[:target].include?('piece') && @user.has_auth?(:designer)
      items = search_cms_pieces(concepts, criteria, sort)
      results << { model: Cms::Piece,
                   items: items,
                   count: items.size }
    end

    if criteria[:target].include?('layout') && @user.has_auth?(:designer)
      items = search_cms_layouts(concepts, criteria, sort)
      results << { model: Cms::Layout,
                   items: items,
                   count: items.size }
    end

    if criteria[:target].include?('data_text')
      items = search_cms_data_texts(concepts, criteria, sort)
      results << { model: Cms::DataText,
                   items: items,
                   count: items.size }
    end

    if criteria[:target].include?('data_file')
      items = search_cms_data_files(concepts, criteria, sort)
      results << { model: Cms::DataFile,
                   items: items,
                   count: items.size }
    end

    results
  end

  def replace(criteria)
    results = search(criteria)

    results.each do |result|
      model = result[:model]
      ids = result[:items].map(&:id)

      @columns[model].each do |column|
        model.where(id: ids).replace_for_all(column, criteria[:keyword], criteria[:replace_word])
      end
    end
    
    if criteria[:target].include?('gp_article') || criteria[:target].include?('node_page')
      Cms::RebuildLinkJob.perform_later(Core.site)
    end
  end

  private

  def load_target_concepts(criteria)
    if criteria[:target_concept] == 'current'
      [@current_concept]
    elsif @user.has_auth?(:manager)
      @site.concepts
    else
      @site.concepts.readable_for(@user).to_tree.flat_map(&:descendants)
    end
  end

  def load_gp_article_contents(concepts)
    GpArticle::Content::Doc.in_site(@site)
                           .where(concept_id: concepts.map(&:id))
                           .order(:id)
  end

  def search_gp_article_docs(content, criteria, sort)
    docs = GpArticle::Doc.where(content_id: content.id)
    publics = docs.where(state: 'public')
    non_publics = docs.where.not(state: 'public')

    items = [publics,
             non_publics.editable,
             non_publics.creator_or_approvables(@user)].reduce(:union)
    items.search_with_text(@columns[GpArticle::Doc], criteria[:keyword])
         .order(sort[:key] => sort[:order])
  end

  def search_cms_nodes(concepts, criteria, sort)
    Cms::Node.in_site(@site)
             .where(model: "Cms::Page", concept_id: concepts.map(&:id))
             .search_with_text(@columns[Cms::Node], criteria[:keyword])
             .order(sort[:key] => sort[:order])
  end

  def search_cms_pieces(concepts, criteria, sort)
    Cms::Piece.in_site(@site)
          .where(concept_id: concepts.map(&:id))
          .search_with_text(@columns[Cms::Piece], criteria[:keyword])
          .or(Cms::Piece.where(id: search_cms_piece_settings(concepts, criteria).pluck(:piece_id)))
          .order(sort[:key] => sort[:order])
  end

  def search_cms_piece_settings(concepts, criteria)
    Cms::PieceSetting.in_site(@site)
                     .joins(:piece)
                     .where(Cms::Piece.arel_table[:concept_id].in(concepts.map(&:id)))
                     .where(name: @setting_names[Cms::PieceSetting])
                     .search_with_text(@columns[Cms::PieceSetting], criteria[:keyword])
  end

  def search_cms_layouts(concepts, criteria, sort)
    Cms::Layout.in_site(@site)
               .where(concept_id: concepts.map(&:id))
               .search_with_text(@columns[Cms::Layout], criteria[:keyword])
               .order(sort[:key] => sort[:order])
  end

  def search_cms_data_texts(concepts, criteria, sort)
    Cms::DataText.in_site(@site)
                 .where(concept_id: concepts.map(&:id))
                 .search_with_text(@columns[Cms::DataText], criteria[:keyword])
                 .order(sort[:key] => sort[:order])
  end

  def search_cms_data_files(concepts, criteria, sort)
    Cms::DataFile.in_site(@site)
                 .where(concept_id: concepts.map(&:id))
                 .search_with_text(@columns[Cms::DataFile], criteria[:keyword])
                 .order(sort[:key] => sort[:order])
  end
end
