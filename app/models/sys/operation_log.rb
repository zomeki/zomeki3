class Sys::OperationLog < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Site
  include Cms::Model::Rel::Site

  default_scope { order(updated_at: :desc) }

  ACTION_OPTIONS = [["作成","create"], ["更新","update"], ["承認","recognize"], ["承認","approve"], ["削除","destroy"], ["公開","publish"], ["非公開","close"], ["期限切れ","expire"], ["ログイン","login"], ["ログアウト","logout"]]

  belongs_to :loggable, :polymorphic => true
  belongs_to :user, :class_name => 'Sys::User'

  validates :loggable, :presence => true
  validates :user, :presence => true

  scope :search_with_params, ->(params = {}) {
    rel = all
    params.each do |n, v|
      next if v.to_s == ''
      case n
      when 's_id'
        rel.where!(id: v)
      when 's_user_id'
        rel.where!(user_id: v)
      when 's_action'
        rel.where!(action: v == 'recognize' ? ['recognize', 'approve'] : v)
      when 's_keyword'
        rel = rel.search_with_text(:item_name, :item_model, v)
      when 'start_date'
        rel.where!(arel_table[:created_at].gteq(v))
      when 'close_date'
        date = Date.strptime(params[:close_date], "%Y-%m-%d") + 1.days rescue nil
        rel.where!(arel_table[:created_at].lteq(date)) if date
      end
    end
    rel
  }

  def action_text
    ACTION_OPTIONS.detect{|o| o.last == action }.try(:first).to_s
  end

  def set_item_info(item)
    self.item_model  = item.class.to_s
    self.item_id     = item.id if item.has_attribute?(:id)
    self.item_name   = item.title if item.has_attribute?(:title)
    self.item_name ||= item.name if item.has_attribute?(:name)
    self.item_name ||= "##{item.id}" if item.has_attribute?(:id)
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
