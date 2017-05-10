class Sys::Process < ApplicationRecord
  self.table_name = "sys_processes"
  include Sys::Model::Base

  ALL_PROCESSES = [
    ["日時指定処理", "sys/tasks/exec"],
    ["音声書き出し", "cms/talk_tasks/exec"],
    ["リンクチェック", "cms/link_checks/exec"],
    ["アクセスランキング取り込み", "rank/ranks/exec"],
    ["フィード取り込み", "feed/feeds/read"],
    ["問合せ取り込み", "survey/answers/pull"],
    ["広告クリック数取り込み", "ad_banner/clicks/pull"],
    ["関連ページ書き出し", "cms/nodes/publish"],
    ["記事ページ書き出し", "gp_article/docs/publish_doc"],
    ["再構築", "/rebuild"]
  ]

  RUNNABLE_PROCESSE_NAMES = [
    "sys/tasks/exec",
    "cms/talk_tasks/exec",
    "cms/link_checks/exec",
    "rank/ranks/exec",
    "feed/feeds/read"
  ]
  RUNNABLE_PROCESSES = ALL_PROCESSES.select { |p| p.last.in?(RUNNABLE_PROCESSE_NAMES) }

  STATES = [["実行中", "running"], ["完了", "closed"], ["停止", "stop"]]

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
        rel.where!(arel_table[:name].matches("%#{v}"))
      when 'start_date'
        rel.where!(arel_table[:started_at].gteq(v))
      when 'close_date'
        date = Date.strptime(params[:close_date], "%Y-%m-%d") + 1.days rescue nil
        rel.where!(arel_table[:started_at].lteq(date)) if date
      end
    end
    rel
  }

  def title
    ALL_PROCESSES.detect { |p| name =~ Regexp.new(p.last) }.try!(:first)
  end

  def status
    STATES.rassoc(state).try!(:last)
  end

  def current_per_total
    str = current.to_s
    str << "/#{total}" if total
    str
  end

  def success_per_total
    str = success.to_s
    str << "/#{total}" if total
    str
  end

  def self.lock(attrs = {})
    raise "lock name is blank." if attrs[:name].blank?

    if attrs[:lock_by]
      proc = self.where(name: attrs[:name]).order(id: :desc)
      proc = proc.where(site_id: attrs[:site_id]) if attrs[:lock_by] == :site
      proc = proc.first
      if proc && proc.state == "running"
        limit = attrs[:time_limit] || 0
        return false if (proc.updated_at.to_i + limit) > Time.now.to_i
      end
    end

    proc = self.new(name: attrs[:name], site_id: attrs[:site_id])
    proc.created_at  = Time.now
    proc.updated_at  = Time.now
    proc.started_at  = Time.now
    proc.closed_at   = nil
    proc.user_id     = Core.user ? Core.user.id : nil
    proc.state       = "running"
    proc.total       = 0
    proc.current     = 0
    proc.success     = 0
    proc.error       = 0
    proc.message     = nil
    proc.interrupt   = nil
    proc.script_options = attrs[:options]
    proc.save
    proc
  end

  def unlock
    self.closed_at = Time.now
    self.state     = "closed"
    return self.save
  end

  def interrupted?
    self.class.uncached do
      item = self.class.select(:interrupt).find_by(id: id)
      self.interrupt = item.interrupt
      return item.interrupt.blank? ? nil : item.interrupt
    end
  end
end
