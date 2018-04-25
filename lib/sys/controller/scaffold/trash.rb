module Sys::Controller::Scaffold::Trash
  def trash(item)
    _trash(item)
  end

  def untrash(item)
    _untrash(item)
  end

  protected

  def _trash(item, options = {}, &block)
    if item.deletable? && item.trash
      location       = options[:location].is_a?(Proc) ? options[:location].call(item) : options[:location] || url_for(action: :index)
      flash[:notice] = options[:notice] || "ごみ箱への移動が完了しました。（#{I18n.l Time.now}）"
      Sys::OperationLog.log(request, item: item)
      yield if block_given?
      respond_to do |format|
        format.html { redirect_to(location) }
        format.xml  { head :ok }
      end
    else
      flash.now[:alert] = 'ごみ箱への移動に失敗しました。'
      respond_to do |format|
        format.html { render :show }
        format.xml  { render xml: item.errors, status: :unprocessable_entity }
      end
    end
  end

  def _untrash(item, options = {}, &block)
    if item.deletable? && item.untrash
      location       = options[:location].is_a?(Proc) ? options[:location].call(item) : options[:location] || url_for(action: :index)
      flash[:notice] = options[:notice] || "ごみ箱からの復元処理が完了しました。（#{I18n.l Time.now}）"
      Sys::OperationLog.log(request, item: item)
      yield if block_given?
      respond_to do |format|
        format.html { redirect_to(location) }
        format.xml  { head :ok }
      end
    else
      flash.now[:alert] = 'ごみ箱からの復元処理に失敗しました。'
      flash.now[:alert] += item.errors.full_messages.to_a.join if item.errors.present?
      respond_to do |format|
        format.html { render :show }
        format.xml  { render xml: item.errors, status: :unprocessable_entity }
      end
    end
  end
end
