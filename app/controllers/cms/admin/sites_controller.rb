require 'yaml/store'

class Cms::Admin::SitesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
  end

  def index
    @item = Cms::Site.new # for search

    @items = Cms::Site.order(:id)
    # システム管理者以外は所属サイトしか操作できない
    @items = @items.where(id: current_user.site_ids) unless current_user.root?
    @items = @items.paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def show
    @item = Cms::Site.find(params[:id])
    return error_auth unless @item.readable?

    load_sns_apps
    @item.load_file_transfer
    @item.load_site_settings

    _show @item
  end

  def new
    return error_auth unless Core.user.root? || Core.user.site_creatable?

    @sns_apps = {}

    @item = Cms::Site.new(
      :state      => 'public',
    )
  end

  def create
    return error_auth unless Core.user.root? || Core.user.site_creatable?

    @sns_apps = {}

    @item = Cms::Site.new(site_params)
    @item.state = 'public'
    @item.portal_group_state = 'visible'
    _create(@item, notice: "登録処理が完了しました。 （反映にはWebサーバの再起動が必要です。）") do

      @item.users << Core.user unless Core.user.root?
      update_configs
      save_sns_apps
    end
  end

  def update
    @item = Cms::Site.find(params[:id])
    @item.attributes = site_params

    @sns_apps = params[:sns_apps]

    _update @item do
      update_configs
      save_sns_apps
      FileUtils.rm_rf Pathname.new(@item.public_smart_phone_path).children if ::File.exist?(@item.public_smart_phone_path) && !@item.publish_for_smart_phone?
    end
  end

  def destroy
    @item = Cms::Site.find(params[:id])
    _destroy(@item) do
      cookies.delete(:cms_site)
      update_configs

    end
  end



  def update_configs
    Cms::Site.generate_apache_configs
    Cms::Site.generate_nginx_configs
  end

  private

  def load_sns_apps
    @sns_apps = {}

    host = URI.parse(@item.full_uri).host
    return unless host

    db = YAML::Store.new(Rails.root.join('config/sns_apps.yml'))
    db.transaction do
      begin
        facebook = db['facebook'][host]
        @sns_apps['facebook_app_id'] = facebook['id']
        @sns_apps['facebook_app_secret'] = facebook['secret']
      rescue => e
        warn_log "Failed to load facebook apps: #{e.message}"
      end

      begin
        twitter = db['twitter'][host]
        @sns_apps['twitter_consumer_key'] = twitter['key']
        @sns_apps['twitter_consumer_secret'] = twitter['secret']
      rescue => e
        warn_log "Failed to load twitter apps: #{e.message}"
      end
    end
  end

  def save_sns_apps
    host = URI.parse(@item.full_uri).host
    return unless host

    sns_apps = params[:sns_apps]

    db = YAML::Store.new(Rails.root.join('config/sns_apps.yml'))
    db.transaction do
      begin
        facebook = db['facebook']
        unless facebook[host].kind_of?(Hash)
          facebook[host] = {}
          facebook['default'].each do |key, value|
            facebook[host][key] = value
          end
        end

        facebook = facebook[host]
        facebook['id'] = sns_apps['facebook_app_id']
        facebook['secret'] = sns_apps['facebook_app_secret']
      rescue => e
        warn_log "Failed to save facebook apps: #{e.message}"
      end

      begin
        twitter = db['twitter']
        unless twitter[host].kind_of?(Hash)
          twitter[host] = {}
          twitter['default'].each do |key, value|
            twitter[host][key] = value
          end
        end

        twitter = twitter[host]
        twitter['key'] = sns_apps['twitter_consumer_key']
        twitter['secret'] = sns_apps['twitter_consumer_secret']
      rescue => e
        warn_log "Failed to save twitter apps: #{e.message}"
      end
    end
  end

  def site_params
    params.require(:item).permit(:body, :full_uri, :in_setting_site_admin_protocol, :in_setting_transfer_dest_dir,
      :in_setting_transfer_dest_domain, :in_setting_transfer_dest_host, :in_setting_transfer_dest_user,
      :mobile_full_uri, :admin_full_uri, :name, :og_description, :og_image, :og_title, :og_type, :related_site,
  end
end
