class Rank::Admin::RanksController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  before_action :options, if: -> { params[:options] }

  keep_params :target

  def pre_dispatch
    @content = Rank::Content::Rank.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)
    return redirect_to(action: :index) if params[:reset_criteria]
  end

  def index
    @terms   = [['すべて', 'all']] + Rank::Rank::TERMS
    @targets = Rank::Rank::TARGETS
    @term    = param_check(@terms,   params[:term])
    @target  = param_check(@targets, params[:target])

    set_options

    @ranks = Rank::TotalsFinder.new(@content.ranks)
                               .search(@content, @term, @target, gp_category: params[:category_content_id],
                                                                 category_type: params[:category_type_id],
                                                                 category: params[:category_id])
                               .paginate(page: params[:page], per_page: params[:limit])

    _index @ranks
  end

  def options
    set_options
    options = params[:category_type_id].present? ? @categories : @category_types
    render html: view_context.options_for_select(options)
  end

  private

  def param_check(ary, str)
    str = ary.first[1] if str.blank? || !ary.flatten.include?(str)
    str
  end

  def set_options
    @category_contents = [['すべて', '']]
    @category_contents += category_content_options

    @category_types = [['すべて', '']]
    @category_types += category_type_options(params[:category_content_id]) if params[:category_content_id].present?

    @categories = [['すべて', '']]
    @categories += category_options(params[:category_type_id]) if params[:category_type_id].present?
  end

  def category_content_options
    GpCategory::Content::CategoryType.where(site_id: Core.site.id).map { |co| [co.name, co.id] }
  end

  def category_type_options(content_id)
    GpCategory::Content::CategoryType.find(content_id).category_types_for_option
  end

  def category_options(category_type_id)
    GpCategory::CategoryType.find(category_type_id).categories_for_option
  end
end
