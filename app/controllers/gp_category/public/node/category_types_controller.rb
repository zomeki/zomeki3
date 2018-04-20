class GpCategory::Public::Node::CategoryTypesController < GpCategory::Public::NodeController
  include GpArticle::Controller::Feed

  def pre_dispatch
    @content = GpCategory::Content::CategoryType.find_by(id: Page.current_node.content.id)
    return http_error(404) unless @content

    @more = (params[:file] =~ /^more($|@)/i)
    @more_options = params[:file].split('@', 3).drop(1) if @more
  end

  def index
    # template module
    if (template = @content.index_template)
      return http_error(404) if params[:page]
      return render_template(template) 
    end

    @category_types = @content.public_category_types.paginate(page: params[:page], per_page: 20)
    @category_types = GpCategory::CategoryTypesPreloader.new(@category_types).preload(:public_node_ancestors)
    return http_error(404) if @category_types.current_page > @category_types.total_pages
  end

  def show
    @category_type = @content.public_category_types.find_by(name: params[:name])
    return http_error(404) unless @category_type

    if params[:format].in?(['rss', 'atom'])
      case @content.category_type_style
      when 'all_docs'
        category_ids = @category_type.public_categories.pluck(:id)
        @docs = GpArticle::Doc.categorized_into(category_ids).except(:order)
                              .order(display_published_at: :desc, published_at: :desc)
        @docs = @docs.date_after(:display_published_at, @content.feed_docs_period.to_i.days.ago) if @content.feed_docs_period.present?
        @docs = @docs.paginate(page: params[:page], per_page: @content.feed_docs_number)
        return render_feed(@docs)
      else
        return http_error(404)
      end
    end

    Page.current_item = @category_type
    Page.title = @category_type.title

    # template module
    if (template = @category_type.template)
      if @more && (tm = template.containing_modules.detect { |m| m.name == @more_options.first })
        return render_more_template(template, tm)
      else
        return http_error(404) if params[:page]
        return render_template(template)
      end
    end

    case @content.category_type_style
    when 'all_docs'
      category_ids = @category_type.public_categories.pluck(:id)
      @docs = GpArticle::Doc.categorized_into(category_ids).except(:order)
                            .order(display_published_at: :desc, published_at: :desc)
                .paginate(page: params[:page], per_page: @content.category_type_docs_number)
      @docs = GpArticle::DocsPreloader.new(@docs).preload(:public_node_ancestors)
      return http_error(404) if @docs.current_page > @docs.total_pages
    else
      return http_error(404) if params[:page].to_i > 1
    end

    if request.mobile?
      render :show_mobile
    else
      render @content.category_type_style if @content.category_type_style.present?
    end
  end

  private

  def render_template(template)
    rendered = template.body.gsub(/\[\[module\/([\w-]+)\]\]/) do |matched|
      if (tm = @content.template_modules.ci_match(name: $1).first)
        Sys::Lib::Controller.render(
          'gp_category/public/template_module/category_types', "#{action_name}_#{tm.module_type}",
          request: request,
          params: params.merge(content: @content, category_type: @category_type, category: @category, template_module: tm)
        )
      else
        ''
      end
    end
    render html: view_context.content_tag(:div, rendered.html_safe, class: 'contentGpCategory contentGpCategoryCategory').html_safe
  end

  def render_more_template(template, template_module)
    res = Sys::Lib::Controller.dispatch(
      'gp_category/public/template_module/category_types', :more, 
      request: request,
      params: params.merge(content: @content, category_type: @category_type, category: @category, template_module: template_module)
    )
    if res.status == 200
      render html: view_context.content_tag(:div, res.body.html_safe, class: 'contentGpCategory contentGpCategoryCategory').html_safe
    else
      http_error(res.status)
    end
  end
end
