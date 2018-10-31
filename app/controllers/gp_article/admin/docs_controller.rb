class GpArticle::Admin::DocsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  include Sys::Controller::Scaffold::Trash
  include Sys::Controller::Scaffold::Publication
  include Sys::Controller::Scaffold::Hold
  include Approval::Controller::Admin::Approval

  layout :select_layout

  before_action :doc_options, only: [:index], if: -> { params[:doc_options] }
  before_action :user_options, only: [:index], if: -> { params[:user_options] }

  before_action :protect_unauthorized_params, only: [:index]
  before_action :check_duplicated_document, only: [:edit]

  keep_params :target, :target_state, :target_public, :sort_key, :sort_order

  def pre_dispatch
    @content = GpArticle::Content::Doc.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)
    return redirect_to url_for(action: :index) if params[:reset_criteria]

    @item = @content.docs.find(params[:id]) if params[:id].present?
  end

  def index
    criteria = doc_criteria
    @items = GpArticle::DocsFinder.new(@content.docs, Core.user)
                                  .search(criteria)
                                  .distinct
                                  .order(updated_at: :desc)
                                  .preload(:prev_edition, :content, creator: [:user, :group])

    if params[:csv]
      csv = GpArticle::DocCsvService.new(@content, @items, GpArticle::Doc::Criteria.new(criteria)).generate
      return send_data platform_encode(csv), type: 'text/csv', filename: "gp_article_docs_#{Time.now.to_i}.csv"
    else
      @items = @items.paginate(page: params[:page], per_page: params[:limit])
    end

    _index @items
  end

  def show
    _show @item
  end

  def new
    @item = @content.docs.build

    if @content.default_category
      @item.in_category_ids = { @content.default_category.category_type_id.to_s => [@content.default_category.id.to_s] }
    end
    if @content.default_template
      @item.template_id = @content.default_template.id
    end
  end

  def create
    @item = @content.docs.build(doc_params)
    @item.replace_words_with_dictionary

    return render :new if check_document

    @item.state = new_state_from_params

    _create(@item, location: location_after_save) do
      if @item.state_approvable?
        send_approval_request_mail(@item)
      elsif @item.state_public?
        publish_by_update(@item)
      end
    end
  end

  def edit
    _hold(@item)
  end

  def update
    @item.attributes = doc_params
    @item.replace_words_with_dictionary

    return render :edit if check_document

    @item.state = new_state_from_params

    _update(@item, location: location_after_save) do
      if @item.state_approvable?
        send_approval_request_mail(@item)
      elsif @item.state_public?
        publish_by_update(@item)
      end
    end
  end

  def destroy
    _destroy(@item)
  end

  def publish
    _publish(@item)
  end

  def close(item)
    _close(@item) do
      send_broken_link_notification
    end
  end

  def duplicate(item)
    if item.duplicate
      flash[:notice] = '複製処理が完了しました。'
    else
      flash[:alert] = '複製処理に失敗しました。'
    end
    redirect_to url_for(action: :index)
  end

  def approve
    _approve @item do
      if @item.state_approved? && @content.publish_after_approved?
        @item.publish
        Sys::OperationLog.log(request, item: @item, do: 'publish')
      end
    end
  end

  def passback
    _passback @item
  end

  def pullback
    _pullback @item
  end

  def batch
    items = GpArticle::Doc.where(id: params.dig(:item, :id)).order(:id)

    case params[:batch_action]
    when 'trash'
      batch_trash(items)
    when 'untrash'
      batch_untrash(items)
    when 'destroy'
      batch_destroy(items)
    else
      redirect_to url_for(action: :index)
    end
  end

  def doc_options
    items = @content.docs.joins(creator: [:group, :user])
                    .where.not(state: 'trashed')
                    .order(serial_no: :desc, id: :desc)

    items = items.where(state: params[:state]) if params[:state].present?
    items = items.categorized_into(params[:category_id]) if params[:category_id].present?
    items = items.where.not(name: params[:exclude]) if params[:exclude].present?

    items = items.where(Sys::Group.arel_table[:id].eq(params[:group_id])) if params[:group_id].present?
    items = items.where(Sys::User.arel_table[:id].eq(params[:user_id])) if params[:user_id].present?

    items = items.map { |item| ["#{item.serial_no}: #{view_context.truncate(item.title, length: 50)}", item.id] }
    render html: view_context.options_for_select([nil] + items), layout: false
  end

  def user_options
    group = Sys::Group.find(params[:group_id])
    render html: view_context.options_from_collection_for_select(group.users, :id, :name), layout: false
  end

  protected

  def protect_unauthorized_params
    unless Core.user.has_auth?(:manager)
      params[:target] = 'user' if params[:target] == 'all'
    end
  end

  def select_layout
    if request.smart_phone? && action_name.in?(%w(new create edit update))
      'admin/gp_article'
    end
  end

  def check_duplicated_document
    item = if @item.will_be_replaced?
             @item.next_edition
           elsif @item.state_public?
             @item.duplicate(:replace)
           end
    redirect_to url_for(action: :edit, id: item) if item
  end

  def check_document
    if params[:link_check_in_body]
      @item.link_check_results = @item.check_links
      return true
    end

    if params[:accessibility_check]
      @item.modify_accessibility if @item.in_modify_accessibility_check == '1'
      @item.accessibility_check_results = @item.check_accessibility
      return true
    end
  end

  def new_state_from_params
    state = params.keys.detect { |k| k =~ /^commit_/ }.to_s.sub(/^commit_/, '')
    if @content.doc_state_options(Core.user).map(&:last).include?(state)
      state
    else
      nil
    end
  end

  def location_after_save
    lambda { |doc| url_for(action: :edit, id: doc) } if @item.state_draft?
  end

  def publish_by_update(item)
    if item.publish
      flash[:notice] = '公開処理が完了しました。'
    else
      flash[:alert] = '公開処理に失敗しました。'
    end
  end

  def send_broken_link_notification
    return unless @content.notify_broken_link?
    if @item.state_public? || @item.state_closed?
      @item.backlinked_items.each do |doc|
        GpArticle::Admin::Mailer.broken_link_notification(@item, doc).deliver_now
      end
    end
  end

  private

  def doc_criteria
    criteria = params[:criteria] ? params[:criteria].to_unsafe_h : {}

    if params[:target_public].blank?
      if Core.user.has_auth?(:manager)
        params[:target] = 'all' if params[:target].blank?
        params[:target_state] = 'processing' if params[:target_state].blank?
      else
        params[:target] = 'user' if params[:target].blank?
        params[:target_state] = 'processing' if params[:target_state].blank?
      end
    end

    if params[:target] == '' && params[:target_state] == ''
      criteria[:target] = 'all'
      criteria[:target_state] = 'public'
    else
      criteria[:target] = params[:target]
      criteria[:target_state] = params[:target_state]
    end

    criteria[:sort_key] = params[:sort_key]
    criteria[:sort_order] = params[:sort_order]

    criteria
  end

  def doc_params
    params.require(:item).permit(
      :template_id, :title, :href, :target, :subtitle, :summary, :list_image,
      :lang, :body, :body_more, :body_more_link_text,
      :feature_1, :feature_2, :raw_tags, :qrcode_state, :display_published_at, :display_updated_at, :keep_display_updated_at,
      :event_state, :event_will_sync, :event_note,
      :marker_state, :navigation_state, :marker_sort_no, :marker_icon_category_id, :mobile_title, :mobile_body,
      :concept_id, :layout_id, :name, :filename_base, :terminal_pc_or_smart_phone, :terminal_mobile,
      :meta_description, :meta_keywords, :og_type, :og_title, :og_description, :og_image, :remark,
      :in_tmp_id, :in_ignore_link_check, :in_ignore_accessibility_check, :in_modify_accessibility_check,
      :template_values => params[:item][:template_values].try(:keys),
      :creator_attributes => [:id, :group_id, :user_id],
      :tasks_attributes => [:id, :name, :process_at],
      :inquiries_attributes => [:id, :state, :group_id, :_destroy],
      :maps_attributes => [:id, :name, :title, :map_lat, :map_lng, :map_zoom, :markers_attributes => [:id, :name, :lat, :lng]],
      :editable_groups_attributes => [:id, :group_id],
      :related_docs_attributes => [:id, :name, :content_id, :_destroy],
      :periods_attributes => [:id, :started_on, :ended_on],
      :in_approval_flow_ids => [],
    ).tap do |permitted|
      [:in_file_names, :in_category_ids, :in_event_category_ids, :in_marker_category_ids, :in_approval_assignment_ids].each do |key|
        permitted[key] = params[:item][key].to_unsafe_h if params[:item][key]
      end
    end
  end
end
