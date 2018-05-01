module Sys::Controller::Scaffold::Base
  ALLOWED_DO_PARAMS = %w(recognize publish close duplicate duplicate_for_replace download trash untrash)

  def edit
    show
  end

  def batch_destroy(items)
    _batch_destroy(items)
  end

  protected

  def _index(items)
    respond_to do |format|
      format.html { render }
      format.xml  { render xml: items.to_xml(dasherize: false, root: 'items') }
    end
  end

  def _show(item)
    if (idx = ALLOWED_DO_PARAMS.index(params[:do]))
      return public_send(ALLOWED_DO_PARAMS[idx], item)
    end
    respond_to do |format|
      format.html { render }
      format.xml  { render xml: item.to_xml(dasherize: false, root: 'item') }
    end
  end

  def _create(item, options = {}, &block)
    if item.creatable? && item.save
      item.reload if item.respond_to?(:reload) rescue nil
      status         = params[:_created_status] || :created
      location       = options[:location].is_a?(Proc) ? options[:location].call(item) : options[:location] || url_for(action: :index)
      flash[:notice] = options[:notice] || "登録処理が完了しました。（#{I18n.l Time.now}）"
      Sys::OperationLog.log(request, item: item)
      yield if block_given?
      respond_to do |format|
        format.html { redirect_to(location) }
        format.xml  { render(xml: item.to_xml(dasherize: false), status: status, location: location) }
      end
    else
      flash.now[:alert] = '登録処理に失敗しました。'
      respond_to do |format|
        format.html { render :new }
        format.xml  { render xml: item.errors, status: :unprocessable_entity }
      end
    end
  end

  def _update(item, options = {}, &block)
    if item.editable? && item.save
      item.reload if item.respond_to?(:reload) rescue nil
      location       = options[:location].is_a?(Proc) ? options[:location].call(item) : options[:location] || url_for(action: :index)
      Sys::OperationLog.log(request, item: item)
      flash[:notice] = options[:notice] || "更新処理が完了しました。（#{I18n.l Time.now}）"
      yield if block_given?
      respond_to do |format|
        format.html { redirect_to(location) }
        format.xml  { head :ok }
      end
    else
      flash.now[:alert] = '更新処理に失敗しました。'
      respond_to do |format|
        format.html { render :edit }
        format.xml  { render xml: item.errors, status: :unprocessable_entity }
      end
    end
  end

  def _destroy(item, options = {}, &block)
    if item.deletable? && item.destroy
      location       = options[:location].is_a?(Proc) ? options[:location].call(item) : options[:location] || url_for(action: :index)
      flash[:notice] = options[:notice] || "削除処理が完了しました。（#{I18n.l Time.now}）"
      Sys::OperationLog.log(request, item: item)
      yield if block_given?
      respond_to do |format|
        format.html { redirect_to(location) }
        format.xml  { head :ok }
      end
    else
      flash.now[:alert] = '削除処理に失敗しました。'
      respond_to do |format|
        format.html { render :show }
        format.xml  { render xml: item.errors, status: :unprocessable_entity }
      end
    end
  end

  def _batch_destroy(items)
    num = 0
    items.each do |item|
      if item.deletable? && item.destroy
        Sys::OperationLog.log(request, item: item, do: 'destroy')
        num += 1
      end
    end
    redirect_to url_for(action: :index), notice: "削除処理が完了しました。（#{num}件）（#{I18n.l Time.now}）"
  end
end
