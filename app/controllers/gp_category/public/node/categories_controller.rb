class GpCategory::Public::Node::CategoriesController < GpCategory::Public::Node::BaseController
  def show
    @category_type = @content.category_types.find_by(name: params[:category_type_name])
    @category = @category_type.find_category_by_path_from_root_category(params[:category_names])
    return http_error(404) unless @category.try(:public?)

    if params[:format].in?(['rss', 'atom'])
      docs = @category.public_docs.order(display_published_at: :desc, published_at: :desc)
      docs = docs.display_published_after(@content.feed_docs_period.to_i.days.ago) if @content.feed_docs_period.present?
      docs = docs.paginate(page: params[:page], per_page: @content.feed_docs_number)
      return render_feed(docs)
    end

    Page.current_item = @category
    Page.title = @category.title

    # template module
    if (template = @category.inherited_template)
      if @more && (tm = template.containing_modules.detect { |m| m.name == @more_options.first })
        return render_more_template(template, tm)
      else
        return http_error(404) if params[:page]
        return render_template(template)
      end
    end

    per_page = (@more ? 30 : @content.category_docs_number)

    @docs = @category.public_docs.order(display_published_at: :desc, published_at: :desc)
                     .paginate(page: params[:page], per_page: per_page)
    @docs = GpArticle::DocsPreloader.new(@docs).preload(:public_node_ancestors)
    return http_error(404) if @docs.current_page > @docs.total_pages

    if Page.mobile?
      render :show_mobile
    else
      if @more
        render 'more'
      else
        if (style = @content.category_style).present?
          render style
        end
      end
    end
  end

  private

  def render_template(template)
    rendered = template.body.gsub(/\[\[module\/([\w-]+)\]\]/) do |matched|
      if (tm = @content.template_modules.ci_match(name: $1).first)
        Sys::Lib::Controller.render(
          'gp_category/public/template_module/categories', "#{action_name}_#{tm.module_type}",
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
      'gp_category/public/template_module/categories', :more,
      params: params.merge(content: @content, category_type: @category_type, category: @category, template_module: template_module)
    )
    if res.status == 200
      render html: view_context.content_tag(:div, res.body.html_safe, class: 'contentGpCategory contentGpCategoryCategory').html_safe
    else
      http_error(res.status)
    end
  end
end
