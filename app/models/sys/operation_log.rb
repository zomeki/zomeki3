class Sys::OperationLog < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Rel::Site

  default_scope { order(id: :desc) }

  enum_ish :action, [:create, :update, :recognize, :approve, :destroy, :publish, :close, :expire, :trash, :untrash, :login, :logout]

  belongs_to :user, required: true

  def set_item_info(item)
    self.item_model  = item.class.to_s
    self.item_id     = item.id if item.respond_to?(:id)
    self.item_name   = item.title if item.respond_to?(:title)
    self.item_name ||= item.name if item.respond_to?(:name)
    self.item_name ||= "##{item.id}" if item.respond_to?(:id)
    self.item_name   = item_name.to_s.split(//u).slice(0, 80).join if item_name.present?
  end

  def self.log(request, options = {})
    params = request.params

    log = self.new
    log.uri       = Core.request_uri
    log.action    = options[:do].presence || params[:do].presence || params[:action]
    log.ipaddr    = request.remote_ip
    log.site_id   = Core.site.id rescue 0

    if user = options[:user]
      log.user_id   = user.id
      log.user_name = user.name
    elsif user = Core.user
      log.user_id   = user.id
      log.user_name = user.name
    end

    log.set_item_info(options[:item]) if options[:item]
    log.save(validate: false)
  end

  def self.script_log(options = {})
    unless options[:action]
      return self
    end

    log = self.new
    log.uri       = ''
    log.action    = options[:action]
    log.site_id   = options[:site].id rescue 0

    log.user_id   = 0
    log.user_name = options[:user_name] || 'CMS'

    log.set_item_info(options[:item]) if options[:item]
    log.save(validate: false)
  end
end
