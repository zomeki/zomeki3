class GpCategory::Public::Node::CategoriesController < GpCategory::Public::Node::BaseController
  def show
    category_type = @content.category_types.find_by(name: params[:category_type_name])
    @category = category_type.find_category_by_path_from_root_category(params[:category_names])
    return http_error(404) unless @category.try(:public?)

    if params[:format].in?(['rss', 'atom'])
      docs = @category.public_docs.order(display_published_at: :desc, published_at: :desc)
      docs = docs.display_published_after(@content.feed_docs_period.to_i.days.ago) if @content.feed_docs_period.present?
      docs = docs.paginate(page: params[:page], per_page: @content.feed_docs_number)
      return render_feed(docs)
    end

    Page.current_item = @category
    Page.title = @category.title

    per_page = (@more ? 30 : @content.category_docs_number)

    if (template = @category.inherited_template)
      if @more
        @template_module = template.containing_modules.detect { |m| m.name == @more_options.first }
        @docs = if template_module && template_module.module_type.in?(%w(docs_2 docs_4 docs_6))
                  find_public_docs_with_category_id(@category.id)
                else
                  find_public_docs_with_category_id(@category.public_descendants.map(&:id))
                end

        if @template_module && @template_module.gp_article_content_ids.present?
          @docs.where!(content_id: @template_module.gp_article_content_ids)
        end

        if (filter = @more_options[1])
          prefix, code_or_name = filter.split('_', 2)

          case prefix
          when 'c'
            return http_error(404) unless category_type.internal_category_type

            internal_category = category_type.internal_category_type.public_root_categories.find_by(name: code_or_name)
            return http_error(404) unless internal_category

            categorizations = GpCategory::Categorization.where(categorizable_type: 'GpArticle::Doc', categorized_as: 'GpArticle::Doc',
                                                               categorizable_id: @docs.pluck(:id),
                                                               category_id: internal_category.public_descendants.map(&:id))
            @docs = GpArticle::Doc.where(id: categorizations.pluck(:categorizable_id))
          when 'g'
            group = Sys::Group.in_site(Page.site).where(code: code_or_name).first
            return http_error(404) unless group
            @docs = @docs.joins(creator: :group).where(Sys::Group.arel_table[:id].eq(group.id))
          end
        end

        @docs = case @content.docs_order
          when 'published_at_desc'
            @docs.order(display_published_at: :desc, published_at: :desc)
          when 'published_at_asc'
            @docs.order(display_published_at: :asc, published_at: :asc)
          when 'updated_at_desc'
            @docs.order(display_updated_at: :desc, updated_at: :desc)
          when 'updated_at_asc'
            @docs.order(display_updated_at: :asc, updated_at: :asc)
          else
            @docs.order(display_published_at: :desc, published_at: :desc)
          end

        @docs = @docs.paginate(page: params[:page], per_page: per_page)
        return http_error(404) if @docs.current_page > @docs.total_pages
        render :more
      else
        return http_error(404) if params[:page]
        vc = view_context
        rendered = template.body.gsub(/\[\[module\/([\w-]+)\]\]/) do |matched|
            tm = @content.template_modules.find_by(name: $1)
            next unless tm

            case tm.module_type
            when 'categories_1', 'categories_2', 'categories_3'
              if vc.respond_to?(tm.module_type)
                @category.public_children.inject(''){|tags, child|
                  tags << vc.content_tag(:section, class: child.name) do
                      html = vc.content_tag(:h2, vc.link_to(child.title, child.public_uri))
                      html << vc.send(tm.module_type, template_module: tm,
                                      categories: child.public_children)
                    end
                }
              end
            when 'categories_summary_1', 'categories_summary_2', 'categories_summary_3'
              if vc.respond_to?(tm.module_type)
                @category.public_children.inject(''){|tags, child|
                  tags << vc.content_tag(:section, class: child.name) do
                      title_tag = vc.content_tag(:h2, child.title)
                      title_tag << vc.content_tag(:span, child.description, class: 'category_summary') if child.description.present?
                      html = vc.link_to(title_tag, child.public_uri)
                      html << vc.send(tm.module_type, template_module: tm,
                                      categories: child.public_children)
                    end
                }
              end
            when 'docs_1', 'docs_2'
              if vc.respond_to?(tm.module_type)
                docs = case tm.module_type
                       when 'docs_1'
                         find_public_docs_with_category_id(@category.public_descendants.map(&:id))
                       when 'docs_2'
                         find_public_docs_with_category_id(@category.id)
                       end
                docs = docs.where(content_id: tm.gp_article_content_ids) if tm.gp_article_content_ids.present?

                all_docs = case @content.docs_order
                  when 'published_at_desc'
                    docs.order(display_published_at: :desc, published_at: :desc)
                  when 'published_at_asc'
                    docs.order(display_published_at: :asc, published_at: :asc)
                  when 'updated_at_desc'
                    docs.order(display_updated_at: :desc, updated_at: :desc)
                  when 'updated_at_asc'
                    docs.order(display_updated_at: :asc, updated_at: :asc)
                  else
                    docs.order(display_published_at: :desc, published_at: :desc)
                  end

                docs = all_docs.limit(tm.num_docs)
                vc.send(tm.module_type, template_module: tm,
                        ct_or_c: @category, docs: docs, all_docs: all_docs)
              end
            when 'docs_3', 'docs_4'
              if vc.respond_to?(tm.module_type) && category_type.internal_category_type
                docs = case tm.module_type
                       when 'docs_3'
                         find_public_docs_with_category_id(@category.public_descendants.map(&:id))
                       when 'docs_4'
                         find_public_docs_with_category_id(@category.id)
                       end
                docs = docs.where(content_id: tm.gp_article_content_ids) if tm.gp_article_content_ids.present?

                categorizations = GpCategory::Categorization.where(categorizable_type: 'GpArticle::Doc', categorizable_id: docs.pluck(:id), categorized_as: 'GpArticle::Doc')
                vc.send(tm.module_type, template_module: tm,
                        ct_or_c: @category,
                        categories: category_type.internal_category_type.public_root_categories, categorizations: categorizations)
              end
            when 'docs_5', 'docs_6'
              if vc.respond_to?(tm.module_type)
                docs = case tm.module_type
                       when 'docs_5'
                         find_public_docs_with_category_id(@category.public_descendants.map(&:id))
                       when 'docs_6'
                         find_public_docs_with_category_id(@category.id)
                       end
                docs = docs.where(content_id: tm.gp_article_content_ids) if tm.gp_article_content_ids.present?

                docs = docs.joins(:creator => :group)
                groups = Sys::Group.where(id: docs.select(Sys::Group.arel_table[:id]).distinct)
                vc.send(tm.module_type, template_module: tm,
                        ct_or_c: @category,
                        groups: groups, docs: docs)
              end
            when 'docs_7', 'docs_8'
              if view_context.respond_to?(tm.module_type)
                docs = find_public_docs_with_category_id(@category.public_descendants.map(&:id))
                docs = docs.where(content_id: tm.gp_article_content_ids) if tm.gp_article_content_ids.present?

                categorizations = GpCategory::Categorization.where(categorizable_type: 'GpArticle::Doc', categorizable_id: docs.pluck(:id), categorized_as: 'GpArticle::Doc')
                vc.send(tm.module_type, template_module: tm,
                        categories: @category.children, categorizations: categorizations)
              end
            else
              ''
            end
          end

        render html: vc.content_tag(:div, rendered.html_safe, class: 'contentGpCategory contentGpCategoryCategory').html_safe
      end
    else
      @docs = @category.public_docs.order(display_published_at: :desc, published_at: :desc)
        .paginate(page: params[:page], per_page: per_page)
        .preload_assocs(:public_node_ancestors_assocs, :public_index_assocs)
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
  end
end
