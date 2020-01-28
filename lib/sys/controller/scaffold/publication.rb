module Sys::Controller::Scaffold::Publication

  def publish(item)
    _publish(item)
  end

  def close(item)
    _close(item)
  end
  
  def batch_publish(items)
    _batch_publish(items)
  end

  def batch_close(items)
    _batch_close(items)
  end

  protected

  def _publish(item, options = {}, &block)
    if item.publishable? && item.publish
      location       = options[:location] || url_for(action: :index)
      flash[:notice] = options[:notice] || '公開処理が完了しました。'
      Sys::OperationLog.log(request, item: item)
      yield if block_given?
      respond_to do |format|
        format.html { redirect_to(location) }
        format.xml  { head :ok }
      end
    else
      flash[:alert] = '公開処理に失敗しました。'
      respond_to do |format|
        format.html { redirect_to url_for(action: :show) }
        format.xml  { render xml: item.errors, status: :unprocessable_entity }
      end
    end
  end

  def _close(item, options = {}, &block)
    if item.closable? && item.close
      location       = options[:location] || url_for(action: :index)
      flash[:notice] = options[:notice] || '非公開処理が完了しました。'
      Sys::OperationLog.log(request, item: item)
      yield if block_given?
      respond_to do |format|
        format.html { redirect_to(location) }
        format.xml  { head :ok }
      end
    else
      flash[:alert] = '非公開処理に失敗しました。'
      respond_to do |format|
        format.html { redirect_to url_for(action: :show) }
        format.xml  { render xml: item.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def _batch_publish(items)
    num = 0
    items.each do |item|
      if item.publishable? && item.publish
        Sys::OperationLog.log(request, item: item, do: 'publish')
        num += 1
      end
    end
    redirect_to url_for(action: :index), notice: "公開処理が完了しました。（#{num}件）（#{I18n.l Time.now}）"
  end

  def _batch_close(items)
    num = 0
    items.each do |item|
      if item.closable? && item.close
        Sys::OperationLog.log(request, item: item, do: 'close')
        num += 1
      end
    end
    redirect_to url_for(action: :index), notice: "非公開処理が完了しました。（#{num}件）（#{I18n.l Time.now}）"
  end
  
end
