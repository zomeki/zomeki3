class Sys::ProcessLog < ApplicationRecord
  include Sys::Model::Base

  belongs_to :user, class_name: 'Sys::User'
  belongs_to :parent, foreign_key: :parent_id, class_name: 'Sys::Process'
  attr_accessor :title

  PROCESSE_LIST = [
    ["日時指定処理", "sys/tasks/exec"],
    ["音声書き出し", "cms/talk_tasks/exec"],
    ["アクセスランキング取り込み", "rank/ranks/exec"],
    ["フィード取り込み", "feed/feeds/read"],
    ["問合せ取り込み", "survey/answers/pull"],
    ["広告クリック数取り込み", "ad_banner/clicks/pull"],
    ["関連ページ書き出し", "/publish"],
    ["関連ページ書き出し", "/publish_doc"],
    ["再構築", "/rebuild"]
  ]

  def summary_lael
    PROCESSE_LIST.each{|a| return a[0] if name =~ Regexp.new(a[1]) }
    return nil
  end

  def to_base_model
    item = Sys::Process.new(attributes.except(self.class.primary_key, 'process_id'))
    item
  end

  scope :search_with_params, ->(params = {}) {
    rel = all
    params.each do |n, v|
      next if v.to_s == ''
      case n
      when 's_id'
        rel.where!(id: v)
      when 's_user_id'
        rel.where!(user_id: v)
      when 's_name'
        rel.where!(Sys::ProcessLog.arel_table[:name].matches("%#{v}%"))
      when 'start_date'
        rel.where!(arel_table[:started_at].gteq(v))
      when 'close_date'
        date = Date.strptime(params[:close_date], "%Y-%m-%d") + 1.days rescue nil
        rel.where!(arel_table[:started_at].lteq(date)) if date
      end
    end
    rel
  }

end
