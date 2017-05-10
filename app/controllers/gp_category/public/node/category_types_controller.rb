class GpCategory::Public::Node::CategoryTypesController < GpCategory::Public::Node::BaseController
  def index
    # template module
    if (template = @content.index_template)
      return http_error(404) if params[:page]
      return render_template(template) 
    end

    @category_types = @content.public_category_types.paginate(page: params[:page], per_page: 20)
      .preload_assocs(:public_node_ancestors_assocs)
    return http_error(404) if @category_types.current_page > @category_types.total_pages

    render :index_mobile if Page.mobile?
  end

  def show
    @category_type = @content.public_category_types.find_by(name: params[:name])
    return http_error(404) unless @category_type

    if params[:format].in?(['rss', 'atom'])
      case @content.category_type_style
      when 'all_docs'
        category_ids = @category_type.public_categories.pluck(:id)
        @docs = find_public_docs_with_category_id(category_ids).order(display_published_at: :desc, published_at: :desc)
        @docs = @docs.display_published_after(@content.feed_docs_period.to_i.days.ago) if @content.feed_docs_period.present?
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
      @docs = find_public_docs_with_category_id(category_ids).order(display_published_at: :desc, published_at: :desc)
        .paginate(page: params[:page], per_page: @content.category_type_docs_number)
        .preload_assocs(:public_node_ancestors_assocs, :public_index_assocs).to_a
      return http_error(404) if @docs.current_page > @docs.total_pages
    else
      return http_error(404) if params[:page].to_i > 1
    end

    if Page.mobile?
      render :show_mobile
    else
      render @content.category_type_style if @content.category_type_style.present?
    end
  end

  private

  def render_template(template)
    rendered = template.body.gsub(/\[\[module\/([\w-]+)\]\]/) do |matched|
      if (tm = @content.template_modules.find_by(name: $1))
        Sys::Lib::Controller.render(
          'gp_category/public/template_module/category_types', "#{action_name}_#{tm.module_type}",
          params: params.merge(content: @content, category_type: @category_type, category: @category, template_module: tm))
      else
        ''
      end
    end
    render html: view_context.content_tag(:div, rendered.html_safe, class: 'contentGpCategory contentGpCategoryCategory').html_safe
  end

  def render_more_template(template, template_module)
    res = Sys::Lib::Controller.dispatch(
      'gp_category/public/template_module/category_types', :more, 
      params: params.merge(content: @content, category_type: @category_type, category: @category, template_module: template_module))
    if res.status == 200
      render html: view_context.content_tag(:div, res.body.html_safe, class: 'contentGpCategory contentGpCategoryCategory').html_safe
    else
      http_error(res.status)
    end
  end
end
