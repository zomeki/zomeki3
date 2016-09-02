class GpArticle::Admin::DocsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  include Sys::Controller::Scaffold::Publication

  include Cms::ApiGpCalendar
  include GpArticle::DocsCommon

  before_action :hold_document, only: [:edit]
  before_action :check_intercepted, only: [:update]

  def pre_dispatch
    return http_error(404) unless @content = GpArticle::Content::Doc.find_by(id: params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
    return redirect_to(request.env['PATH_INFO']) if params[:reset_criteria]

    @item = @content.docs.find(params[:id]) if params[:id].present?
  end

  def index
    if params[:options]
      @items = if params[:category_id]
                 if (category = GpCategory::Category.find_by(id: params[:category_id]))
                   params[:public] ? category.public_docs : category.docs
                 else
                   category.docs.none
                 end
               else
                 params[:public] ? @content.public_docs : @content.docs
               end

      if params[:exclude]
        docs_table = @items.table
        @items = @items.where(docs_table[:name].not_eq(params[:exclude]))
      end

      if params[:group_id] || params[:user_id]
        inners = []
        if params[:group_id]
            groups = Sys::Group.arel_table
            inners << :group
        end
        if params[:user_id]
            users = Sys::User.arel_table
            inners << :user
        end
        @items = @items.joins(:creator => inners)

        @items = @items.where(groups[:id].eq(params[:group_id])) if params[:group_id]
        @items = @items.where(users[:id].eq(params[:user_id])) if params[:user_id]
      end

      return render('index_options', layout: false)
    end

    criteria = params[:criteria] || {}

    case params[:target]
    when 'all'
      # No criteria
    when 'draft'
      criteria[:state] = 'draft'
      criteria[:touched_user_id] = Core.user.id
    when 'public'
      criteria[:state] = 'public'
      criteria[:touched_user_id] = Core.user.id
    when 'closed'
      criteria[:state] = 'closed'
      criteria[:touched_user_id] = Core.user.id
    when 'approvable'
      criteria[:approvable] = true
      criteria[:state] = 'approvable'
    when 'approved'
      criteria[:approvable] = true
      criteria[:state] = 'approved'
    else
      criteria[:editable] = true
    end

    @items = GpArticle::Doc.content_and_criteria(@content, criteria)
      .order(updated_at: :desc)
      .paginate(page: params[:page], per_page: 30)

    _index @items
  end

  def show
    _show @item
  end

  def new
    @item = @content.docs.build

    if @content.default_category
      @item.in_category_ids = { @content.default_category.content_type_id.to_s => [@content.default_category.id.to_s] }
    end

    render 'new_smart_phone', layout: 'admin/gp_article_smart_phone' if Page.smart_phone?
  end

  def create
    failed_template = Page.smart_phone? ? {template: "#{controller_path}/new_smart_phone", layout: 'admin/gp_article_smart_phone'}
                                        : {action: 'new'}
    new_state = params.keys.detect{|k| k =~ /^commit_/ }.try(:sub, /^commit_/, '')
    @item = @content.docs.build(doc_params)
    @item.set_inquiry_group if Core.user.root?

    @item.validate_word_dictionary # replace validate word

    if params[:link_check_in_body]
      @item.link_check_results = @item.check_links_in_body
      return render(failed_template)
    end

    if params[:accessibility_check]
      @item.modify_accessibility if @item.in_modify_accessibility_check == '1'
      @item.accessibility_check_results = @item.check_accessibility
      return render(failed_template)
    end

    @item.state = new_state if new_state.present? && @item.class::STATE_OPTIONS.any?{|v| v.last == new_state }

    location = ->(d){ edit_gp_article_doc_url(@content, d) } if @item.state_draft?
    _create(@item, location: location, failed_template: failed_template) do

      @item = @content.docs.find_by(id: @item.id)
      @item.send_approval_request_mail if @item.state_approvable?

      publish_by_update(@item) if @item.state_public?

      share_to_sns(@item) if @item.state_public?
      sync_events_export
    end
  end

  def edit
    if @item.will_be_replaced?
      return redirect_to(edit_gp_article_doc_url(@content, @item.next_edition))
    elsif @item.state_public?
      return redirect_to(edit_gp_article_doc_url(@content, @item.duplicate(:replace)))
    end
    render 'edit_smart_phone', layout: 'admin/gp_article_smart_phone' if Page.smart_phone?
  end

  def update
    failed_template = Page.smart_phone? ? {template: "#{controller_path}/edit_smart_phone", layout: 'admin/gp_article_smart_phone'}
                                        : {action: 'edit'}
    new_state = params.keys.detect{|k| k =~ /^commit_/ }.try(:sub, /^commit_/, '')
    @item.attributes = doc_params
    @item.set_inquiry_group if Core.user.root?

    @item.validate_word_dictionary #replace validate word

    if params[:link_check_in_body]
      @item.link_check_results = @item.check_links_in_body
      return render(failed_template)
    end

    if params[:accessibility_check]
      @item.modify_accessibility if @item.in_modify_accessibility_check == '1'
      @item.accessibility_check_results = @item.check_accessibility
      return render(failed_template)
    end

    @item.state = new_state if new_state.present? && @item.class::STATE_OPTIONS.any?{|v| v.last == new_state }

    location = url_for(action: 'edit') if @item.state_draft?
    _update(@item, location: location, failed_template: failed_template) do
      update_file_names

      @item = @content.docs.find_by(id: @item.id)
      @item.send_approval_request_mail if @item.state_approvable?

      publish_by_update(@item) if @item.state_public?

      @item.close if !@item.public? && !@item.will_replace? # Never use "state_public?" here

      share_to_sns(@item) if @item.state_public?
      sync_events_export

      release_document
    end
  end

  def destroy
    _destroy(@item) do
      send_broken_link_notification(@item) if @content.notify_broken_link? && @item.backlinks.present?
      sync_events_export
    end
  end

  def publish_ruby(item)
    uri = item.public_uri
    uri = (uri =~ /\?/) ? uri.gsub(/\?/, 'index.html.r?') : "#{uri}index.html.r"
    path = "#{item.public_path}.r"
    item.publish_page(render_public_as_string(uri, :site => item.content.site), :path => path, :dependent => :ruby)
  end

  def publish
    @item.update_attribute(:state, 'public')
    _publish(@item) do
      publish_ruby(@item)
      @item.rebuild(render_public_as_string(@item.public_uri, jpmobile: envs_to_request_as_smart_phone),
                    :path => @item.public_smart_phone_path, :dependent => :smart_phone)

      share_to_sns(@item)
      sync_events_export
    end
  end

  def publish_by_update(item)
    return unless item.terminal_pc_or_smart_phone
    if item.publish(render_public_as_string(item.public_uri))
      publish_ruby(item)
      item.rebuild(render_public_as_string(item.public_uri, jpmobile: envs_to_request_as_smart_phone),
                   :path => item.public_smart_phone_path, :dependent => :smart_phone)
      flash[:notice] = '公開処理が完了しました。'
    else
      flash[:alert] = '公開処理に失敗しました。'
    end
  end

  def close(item)
    _close(@item) do
      send_broken_link_notification(@item) if @content.notify_broken_link? && @item.backlinks.present?
      sync_events_export
    end
  end

  def duplicate(item)
    if item.duplicate
      redirect_to url_for(:action => :index), notice: '複製処理が完了しました。'
    else
      redirect_to url_for(:action => :index), alert: '複製処理に失敗しました。'
    end
  end

  def approve
    @item.approve(Core.user, request) if @item.approvers.include?(Core.user)
    redirect_to url_for(:action => :show), notice: '承認処理が完了しました。'
  end

  def passback
    if @item.state_approvable? && @item.approvers.include?(Core.user)
      @item.passback(Core.user, comment: params[:comment])
      redirect_to gp_article_doc_url(@content, @item), notice: '差し戻しが完了しました。'
    else
      redirect_to gp_article_doc_url(@content, @item), notice: '差し戻しに失敗しました。'
    end
  end

  def pullback
    if @item.state_approvable? && @item.approval_requesters.include?(Core.user)
      @item.pullback(comment: params[:comment])
      redirect_to gp_article_doc_url(@content, @item), notice: '引き戻しが完了しました。'
    else
      redirect_to gp_article_doc_url(@content, @item), notice: '引き戻しに失敗しました。'
    end
  end

  protected

  def send_broken_link_notification(item)
    mail_from = 'noreply'

    item.backlinked_docs.each do |doc|
      subject = "【#{doc.content.site.name.presence || 'CMS'}】リンク切れ通知"

      body = <<-EOT
「#{doc.title}」からリンクしている「#{item.title}」が削除されました。
  対象のリンクは次の通りです。

#{item.backlinks.where(doc_id: doc.id).map{|l| "  ・#{l.body} ( #{l.url} )" }.join("\n")}

  次のURLをクリックしてリンクを確認してください。

  #{gp_article_doc_url(content: @content, id: doc.id)}
      EOT

      send_mail(mail_from, doc.creator.user.email, subject, body)
    end
  end

  def hold_document
    unless (holds = @item.holds).empty?
      holds = holds.each{|h| h.destroy if h.user == Core.user }.reject(&:destroyed?)
      alerts = holds.map do |hold|
          in_editing_from = (hold.updated_at.today? ? I18n.l(hold.updated_at, :format => :short_ja) : I18n.l(hold.updated_at, :format => :default_ja))
          "#{hold.user.group.name}#{hold.user.name}さんが#{in_editing_from}から編集中です。"
        end
      flash[:alert] = "<ul><li>#{alerts.join('</li><li>')}</li></ul>".html_safe unless alerts.blank?
    end
    @item.holds.create(user: Core.user)
  end

  def check_intercepted
    unless @item.holds.detect{|h| h.user == Core.user }
      user = @item.operation_logs.first.user
      flash[:alert] = "#{user.group.name}#{user.name}さんが記事を編集したため、編集内容を反映できません。"
      render :action => :edit
    end
  end

  def release_document
    @item.holds.destroy_all
  end

  def update_file_names
    if (file_names = params[:file_names]).kind_of?(Hash)
      new_body = @item.body
      file_names.each do |key, value|
        file = @item.files.where(id: key).first
        next if file.nil? || file.name == value
        new_body = new_body.gsub("file_contents/#{value}", "file_contents/#{file.name}")
      end
      @item.update_columns(body: new_body) unless @item.body == new_body
    end
  end

  def sync_events_export
    if @content.calendar_related? && (calendar_content = @content.gp_calendar_content_event)
      gp_calendar_sync_events_export(doc_or_event: @item, event_content: calendar_content) if calendar_content.event_sync_export?
    end
  end

  private

  def doc_params
    params.require(:item).permit(
      :template_id, :title, :href, :target, :subtitle, :summary, :list_image, :body, :body_more, :body_more_link_text,
      :feature_1, :feature_2, :raw_tags, :qrcode_state, :display_published_at, :display_updated_at, :keep_display_updated_at,
      :event_state, :event_started_on, :event_ended_on, :event_will_sync,
      :marker_state, :marker_icon_category_id, :mobile_title, :mobile_body,
      :concept_id, :layout_id, :name, :filename_base, :terminal_pc_or_smart_phone, :terminal_mobile,
      :meta_description, :meta_keywords, :share_to_sns_with, :og_type, :og_title, :og_description, :og_image,
      :in_tmp_id, :in_ignore_link_check, :in_ignore_accessibility_check, :in_modify_accessibility_check,
      :template_values => params[:item][:template_values].try(:keys),
      :in_tasks => [:publish, :close],
      :inquiries_attributes => [:id, :state, :_destroy,:group_id],
      :in_maps => [:name, :title, :map_lat, :map_lng, :map_zoom, :markers => [:name, :lat, :lng]],
      :in_creator => [:group_id, :user_id],
      :in_editable_groups => [],
      :in_rel_doc_ids => [],
      :in_share_accounts => [],
      :in_approval_flow_ids => [],
    ).tap do |whitelisted|
      whitelisted[:in_category_ids] = params[:item][:in_category_ids]
      whitelisted[:in_event_category_ids] = params[:item][:in_event_category_ids]
      whitelisted[:in_marker_category_ids] = params[:item][:in_marker_category_ids]
      whitelisted[:in_approval_assignment_ids] = params[:item][:in_approval_assignment_ids]
    end
  end
end
