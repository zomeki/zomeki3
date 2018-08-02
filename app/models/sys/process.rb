class Sys::Process < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Rel::Site

  ALL_PROCESSES = [
    ["日時指定処理", "sys/tasks/exec"],
    ["音声書き出し", "cms/talk_tasks/exec"],
    ["リンクチェック", "cms/link_checks/exec"],
    ["アクセスランキング取り込み", "rank/ranks/exec"],
    ["フィード取り込み", "feed/feeds/read"],
    ["問合せ取り込み", "survey/answers/pull"],
    ["広告クリック数取り込み", "ad_banner/clicks/pull"],
    ["関連ページ書き出し", "cms/nodes/publish"],
    ["関連ピース書き出し", "cms/pieces/publish"],
    ["記事ページ書き出し", "gp_article/docs/publish"],
    ["再構築", "/rebuild"],
    ["ファイル転送", "cms/file_transfers/exec"],
    ["メール取り込み", "mailin/filters/exec"]
  ]

  RUNNABLE_PROCESS_NAMES = [
    "sys/tasks/exec",
    "cms/talk_tasks/exec",
    "cms/link_checks/exec",
    "rank/ranks/exec",
    "feed/feeds/read",
    "cms/file_transfers/exec"
  ]
  RUNNABLE_PROCESSES = ALL_PROCESSES.select { |p| p.last.in?(RUNNABLE_PROCESS_NAMES) }

  enum_ish :state, [:running, :closed, :stop]

  def title
    ALL_PROCESSES.detect { |p| name =~ Regexp.new(p.last) }.try!(:first)
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

  def processable?
    return false if name == 'cms/file_transfers/exec' && !Zomeki.config.application['cms.file_transfer']
    state != 'running'
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

  class << self
    def cleanup
      days = Sys::Setting.process_log_keep_days
      return unless days

      Sys::Process.date_before(:created_at, days.days.ago)
                  .find_each(&:destroy)
    end
  end
end
