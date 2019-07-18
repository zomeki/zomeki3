class AdBanner::Admin::BannersController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  keep_params :target, :target_state, :target_public

  def pre_dispatch
    @content = AdBanner::Content::Banner.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)
    @item = @content.banners.find(params[:id]) if params[:id].present?
  end

  def index
    criteria = banner_criteria
    @items = AdBanner::BannersFinder.new(@content.banners)
                                .search(criteria)
                                .distinct
                                .reorder(:sort_no)
                                .paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def show
    _show @item
  end

  def new
    @item = @content.banners.build(site_id: Core.site.id)
  end

  def create
    @item = @content.banners.build(banner_params)
    @item.state = new_state_from_params(@item)
    @item.site_id = Core.site.id
    _create @item
  end

  def update
    @item.attributes = banner_params
    @item.state = new_state_from_params(@item)
    @item.skip_upload if @item.file.blank? && ::File.exist?(@item.upload_path)
    _update @item
  end

  def destroy
    _destroy @item
  end

  def publish
    @item.publish if @item.publishable?
    redirect_to url_for(action: :show), notice: '公開処理が完了しました。'
  end

  def close
    @item.close if @item.closable?
    redirect_to url_for(action: :show), notice: '公開終了処理が完了しました。'
  end

  def file_content
    send_file @item.upload_path, filename: @item.name
  end

  private

  def new_state_from_params(item)
    state = params.keys.detect { |k| k =~ /^commit_/ }.to_s.sub(/^commit_/, '')
    if !@content.banner_state_options(Core.user).map(&:last).include?(state)
      state = nil
    end
    if state == 'approved' && item.tasks.detect { |task| task.name == 'publish' && task.process_at.present? }
      state = 'prepared'
    end
    state
  end

  def banner_criteria
    criteria = params[:criteria] ? params[:criteria].to_unsafe_h : {}

    if params[:target_public].blank?
      if Core.user.has_auth?(:manager)
        params[:target] = 'all' if params[:target].blank?
        params[:target_state] = 'all' if params[:target_state].blank?
      else
        params[:target] = 'user' if params[:target].blank? || params[:target] == 'all'
        params[:target_state] = 'all' if params[:target_state].blank?
      end
    end

    if params[:target] == '' && params[:target_state] == ''
      criteria[:target] = 'all'
      criteria[:target_state] = 'public'
    else
      criteria[:target] = params[:target]
      criteria[:target_state] = params[:target_state]
    end

    criteria
  end

  def banner_params
    params.require(:item).permit(
      :advertiser_contact, :advertiser_email, :advertiser_name, :advertiser_phone,
      :file, :group_id, :name, :sort_no, :title, :alt_text, :url, :sp_url, :target,
      :nofollow, :lazyload,
      :creator_attributes => [:id, :group_id, :user_id],
      :tasks_attributes => [:id, :name, :process_at]
    )
  end
end
