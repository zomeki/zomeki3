class Rank::Admin::RanksController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    @content = Rank::Content::Rank.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)
  end

  def index
    @terms   = [['すべて', 'all']] + Rank::Rank::TERMS
    @targets = Rank::Rank::TARGETS
    @term    = param_check(@terms,   params[:term])
    @target  = param_check(@targets, params[:target])

    options

    @ranks = Rank::TotalsFinder.new(@content.ranks)
                               .search(@content, @term, @target, gp_category: @gp_category, category_type: @category_type, category: @category)
                               .paginate(page: params[:page], per_page: 20)

    _index @ranks
  end

  def remote
    @options = options
    render :partial => 'remote'
  end

  private

  def param_check(ary, str)
    str = ary.first[1] if str.blank? || !ary.flatten.include?(str)
    str
  end

  def option_default
    [['すべて', '']]
  end

  def options
    @gp_category = params[:gp_category].to_i
    @gp_categories = option_default + gp_categories

    @category_type = params[:category_type].to_i
    @category_types = option_default
    @category_types = @category_types + category_types(@gp_category) if @gp_category > 0

    @category = params[:category].to_i
    @categories = option_default
    @categories = @categories + categories(@category_type) if @category_type > 0

    @category_type != 0 ? @categories : @category_types
  end

  def gp_categories
    GpCategory::Content::CategoryType.where(site_id: Core.site.id).map{|co| [co.name, co.id] }
  end

  def category_types(gp_category)
    GpCategory::Content::CategoryType.find_by(id: gp_category).category_types_for_option
  end

  def categories(category_type)
    GpCategory::CategoryType.find(category_type).categories_for_option
  end
end