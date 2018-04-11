class Cms::Admin::Node::PagesController < Cms::Admin::Node::BaseController
  set_model Cms::Node::Page

  def edit
    @item = model.find(params[:id])
    #return error_auth unless @item.readable?

#    @item.in_inquiry = @item.default_inquiry if @item.in_inquiry == {}

    @item.name ||= 'index.html'

    _show @item
  end

  def update
    @item = model.find(params[:id])
    @item.attributes = page_params
    @item.state      = "draft"
    @item.state      = "recognize" if params[:commit_recognize]
    @item.state      = "public"    if params[:commit_public]

    _update @item do
      send_recognition_request_mail(@item) if @item.state == 'recognize'
      publish_by_update(@item) if @item.state == 'public'
      @item.close unless @item.public?

      respond_to do |format|
        format.html { return redirect_to(cms_nodes_path) }
      end
    end
  end

  def recognize(item)
    _recognize(item, location: cms_nodes_path) do
      if @item.state == 'recognized'
        send_recognition_success_mail(@item)
        @item.enqueue_tasks
      end
    end
  end

  def publish(item)
    _publish(item, location: cms_nodes_path)
  end

  def publish_by_update(item)
    if item.publish
      flash[:notice] = "公開処理が完了しました。"
    else
      flash[:notice] = "公開処理に失敗しました。"
    end
  end

  def close(item)
    _close(item, location: cms_nodes_path)
  end

  def duplicate(item)
    if dupe_item = item.duplicate
      flash[:notice] = '複製処理が完了しました。'
      respond_to do |format|
        format.html { redirect_to(cms_nodes_path) }
        format.xml  { head :ok }
      end
    else
      flash[:notice] = "複製処理に失敗しました。"
      respond_to do |format|
        format.html { redirect_to url_for(action: :show) }
        format.xml  { render xml: item.errors, status: :unprocessable_entity }
      end
    end
  end

  def duplicate_for_replace(item)
    if dupe_item = item.duplicate(:replace)
      flash[:notice] = '複製処理が完了しました。'
      respond_to do |format|
        format.html { redirect_to(cms_nodes_path) }
        format.xml  { head :ok }
      end
    else
      flash[:notice] = "複製処理に失敗しました。"
      respond_to do |format|
        format.html { redirect_to url_for(action: :show) }
        format.xml  { render xml: item.errors, status: :unprocessable_entity }
      end
    end
  end

  protected

  def send_recognition_request_mail(item)
    item.recognizers.each do |recognizer|
      next if Core.user.email.blank? || recognizer.email.blank?
      Sys::Admin::RecognitionMailer.recognition_request(item, from: Core.user, to: recognizer).deliver_now
    end
  end

  def send_recognition_success_mail(item)
    return if Core.user.email.blank?
    return if item.recognition.blank? || item.recognition.user.blank? || item.recognition.user.email.blank?
    Sys::Admin::RecognitionMailer.recognition_success(item, from: Core.user, to: item.recognition.user).deliver_now
  end

  private

  def page_params
    params.require(:item).permit(
      :body, :concept_id, :in_recognizer_ids,
      :layout_id, :mobile_body, :mobile_title, :name, :parent_id, :published_at,
      :route_id, :sitemap_sort_no, :sitemap_state, :title,
      :creator_attributes => [:id, :group_id, :user_id],
      :inquiries_attributes => [:id, :state, :group_id, :_destroy],
      :tasks_attributes => [:id, :name, :process_at],
      :in_recognizer_ids => []
    )
  end
end
