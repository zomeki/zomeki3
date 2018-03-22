class GpCategory::Public::TemplateModule::CategoriesController < GpCategory::Public::TemplateModule::BaseController
  def pre_dispatch
    @content = params.delete(:content)
    @category_type = params.delete(:category_type)
    @category = params.delete(:category)
    @template_module = params.delete(:template_module)
  end

  def show_categories_1
    @categories = @category.public_children
  end

  def show_categories_2
    @categories = @category.public_children
  end

  def show_categories_3
    @categories = @category.public_children
  end

  def show_categories_summary_1
    @categories = @category.public_children
  end

  def show_categories_summary_2
    @categories = @category.public_children
  end

  def show_categories_summary_3
    @categories = @category.public_children
  end

  def show_docs_1
    @docs = GpCategory::Category.public_docs_for_template_module(@category, @template_module)
                                .order(@content.translated_docs_order)
                                .paginate(page: 1, per_page: @template_module.num_docs)
    return render plain: '' if @docs.empty?

    render :show_docs_1
  end

  def show_docs_2
    show_docs_1
  end

  def show_docs_3
    return render plain: '' unless @category_type.internal_category_type

    docs = GpCategory::Category.public_docs_for_template_module(@category, @template_module)
    return render plain: '' if docs.empty?

    @categories = @category_type.internal_category_type.public_root_categories
    @category_docs = @categories.each_with_object({}) do |category, hash|
      hash[category.id] = docs.categorized_into(category.public_descendants_ids)
                              .order(@content.translated_docs_order)
                              .paginate(page: 1, per_page: @template_module.num_docs)
    end
    return render plain: '' if @category_docs.all?(&:empty?)

    render :show_docs_3
  end

  def show_docs_4
    show_docs_3
  end

  def show_docs_5
    docs = GpCategory::Category.public_docs_for_template_module(@category, @template_module)
                               .joins(creator: :group)
    return render plain: '' if docs.empty?

    group_ids = docs.pluck(Sys::Group.arel_table[:id])
    @groups = Sys::Group.where(id: group_ids).order(code: :asc)
    @group_docs = @groups.each_with_object({}) do |group, hash|
      hash[group.id] = docs.organized_into(group.id)
                           .order(@content.translated_docs_order)
                           .paginate(page: 1, per_page: @template_module.num_docs)
    end
    return render plain: '' if @group_docs.all?(&:empty?)

    render :show_docs_5
  end

  def show_docs_6
    show_docs_5
  end

  def show_docs_7
    docs = GpCategory::Category.public_docs_for_template_module(@category, @template_module)
    return render plain: '' if docs.empty?

    @categories = @category.public_children
    @category_docs = @categories.each_with_object({}) do |category, hash|
      hash[category.id] = docs.categorized_into(category.public_descendants_ids)
                              .order(@content.translated_docs_order)
                              .paginate(page: 1, per_page: @template_module.num_docs)
    end
    return render plain: '' if @category_docs.all?(&:empty?)

    render :show_docs_7
  end

  def show_docs_8
    show_docs_7
  end

  def more
    @docs = GpCategory::Category.public_docs_for_template_module(@category, @template_module)

    if (filter = @more_options[1])
      prefix, code_or_name = filter.split('_', 2)
      case prefix
      when 'c'
        return render plain: '', status: 404 unless @category_type.internal_category_type
        internal_category = @category_type.internal_category_type.public_root_categories.find_by(name: code_or_name)
        return render plain: '', status: 404 unless internal_category
        @docs = @docs.categorized_into(internal_category.public_descendants_ids)
      when 'g'
        group = Sys::Group.in_site(Page.site).where(code: code_or_name).first
        return render plain: '', status: 404 unless group
        @docs = @docs.organized_into(group.id)
      end
    end

    @docs = @docs.order(@content.translated_docs_order)
                 .paginate(page: params[:page], per_page: 30)
    return render plain: '', status: 404 if @docs.current_page > @docs.total_pages
  end
end
