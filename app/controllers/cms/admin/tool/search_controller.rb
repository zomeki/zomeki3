class Cms::Admin::Tool::SearchController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:creator)
    return redirect_to(action: :index) if params[:reset]
  end

  def index
    @results = []
    return true if params[:do] != 'search'
    return true if params[:keyword].blank?

    concepts = load_target_concepts

    if params[:target] && params[:target][:node_page] && Core.user.has_auth?(:designer)
      @results << {
        title: "固定ページ",
        items: search_cms_nodes(Core.site, concepts, params)
      }
    end

    if params[:target] && params[:target][:gp_article]
      contents = Cms::Content.where(site_id: Core.site.id, model: "GpArticle::Doc", concept_id: concepts.map(&:id))
                             .order(:id)
      contents.each do |content|
        @results << {
          title: "記事：#{content.name}",
          items: search_gp_article_docs(content, params)
        }
      end
    end

    if params[:target] && params[:target][:piece] && Core.user.has_auth?(:designer)
      @results << {
        title: "ピース",
        items: search_cms_pieces(Core.site, concepts, params)
      }
    end

    if params[:target] && params[:target][:layout] && Core.user.has_auth?(:designer)
      @results << {
        title: "レイアウト",
        items: search_cms_layouts(Core.site, concepts, params)
      }
    end

    if params[:target] && params[:target][:data_text]
      @results << {
        title: "テキスト",
        items: search_cms_data_texts(Core.site, concepts, params)
      }
    end

    if params[:target] && params[:target][:data_file]
      @results << {
        title: "ファイル",
        items: search_cms_data_files(Core.site, concepts, params)
      }
    end
  end

  private

  def load_target_concepts
    if params[:target_concept] == 'current'
      [Core.concept]
    elsif Core.user.has_auth?(:manager)
      Core.site.concepts
    else
      Core.site.concepts.roots.flat_map(&:readable_descendants)
    end
  end

  def search_cms_nodes(site, concepts, criteria)
    items = Cms::Node.where(site_id: site.id, model: "Cms::Page", concept_id: concepts.map(&:id))
                     .search_with_text(:title, :body, :mobile_title, :mobile_body, criteria[:keyword])
                     .order(:id)
    items.map { |c|
      {
        id: c.id,
        title: c.title,
        state: c.state,
        state_text: c.state_text,
        concept: c.concept,
        admin_uri: c.admin_uri,
        public_uri: c.public_full_uri
      }
    }
  end

  def search_gp_article_docs(content, criteria)
    items = GpArticle::Doc.where(content_id: content.id)
                          .search_with_text(:title, :subtitle, :summary, :body, :mobile_title, :mobile_body, criteria[:keyword])
                          .order(:id)
    items.map { |c|
      {
        id: c.id,
        title: c.title,
        state: c.state,
        state_text: c.state_text,
        concept: content.concept,
        admin_uri: gp_article_doc_path(c.content, c.id),
        public_uri: c.public_full_uri
      }
    }
  end

  def search_cms_pieces(site, concepts, criteria)
    items = Cms::Piece.where(site_id: site.id, concept_id: concepts.map(&:id))
                      .search_with_text(:name, :title, :view_title, :head, :body, criteria[:keyword])
                      .order(:id)
    items.map { |c|
      {
        id: c.id,
        title: c.title,
        state: c.state,
        state_text: c.state_text,
        concept: c.concept,
        admin_uri: c.admin_uri
      }
    }
  end

  def search_cms_layouts(site, concepts, criteria)
    items = Cms::Layout.where(site_id: site.id, concept_id: concepts.map(&:id))
                       .search_with_text(:name, :title, :head, :body, :mobile_head, :mobile_body, criteria[:keyword])
                       .order(:id)
    items.map { |c|
      {
        id: c.id,
        title: c.title,
        concept: c.concept,
        admin_uri: cms_layout_path(c.concept_id, c.id)
      }
    }
  end

  def search_cms_data_texts(site, concepts, criteria)
    items = Cms::DataText.where(site_id: site.id, concept_id: concepts.map(&:id))
                         .search_with_text(:name, :title, :body, criteria[:keyword])
                         .order(:id)
    items.map { |c|
      {
        id: c.id,
        title: c.title,
        state: c.state,
        state_text: c.state_text,
        concept: c.concept,
        admin_uri: cms_data_text_path(c.concept_id, c.id)
      }
    }
  end

  def search_cms_data_files(site, concepts, criteria)
    items = Cms::DataFile.where(site_id: site.id, concept_id: concepts.map(&:id))
                         .search_with_text(:name, :title, criteria[:keyword])
                         .order(:id)
    items.map { |c|
      {
        id: c.id,
        title: c.title,
        state: c.state,
        state_text: c.state_text,
        concept: c.concept,
        admin_uri: cms_data_file_path(c.concept_id, c.id),
        public_uri: c.public_full_uri
      }
    }
  end
end
