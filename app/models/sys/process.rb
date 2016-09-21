class Sys::Process < ActiveRecord::Base
  self.table_name = "sys_processes"
  include Sys::Model::Base

  PROCESSE_LIST = [
    ["日時指定処理" , "sys/script/tasks/exec"],
    ["音声書き出し"  , "cms/script/talk_tasks/exec"],
    ["アクセスランキング取り込み" , "rank/script/ranks/exec"],
    ["Feed取り込み" , "feed/script/feeds/read"],
  ]

  attr_accessor :title
  after_save :update_history

  has_many :histories, class_name: "Sys::ProcessLog", foreign_key: "process_id", dependent: :destroy

  def status
    labels = {
      "running" => "実行中",
      "closed"  => "完了",
      "stop"    => "停止",
    }
    return labels[state] || state
  end

  def update_history
    item = Sys::ProcessLog.where(name: name, created_at: created_at).first ||
      histories.build(created_at: created_at)
    item.attributes = self.attributes.except(self.class.primary_key)
    item.save
  end

  def self.lock(attrs = {})
    raise "lock name is blank." if attrs[:name].blank?

    if proc = self.find_by(name: attrs[:name])
      #if proc.closed_at.nil?
      if proc.state == "running"
        kill = attrs[:time_limit] || 0
        return false if (proc.updated_at.to_i + kill) > Time.now.to_i
      end
    end
    attrs.delete(:time_limit)

    proc ||= new
    proc.created_at  = DateTime.now
    proc.updated_at  = DateTime.now
    proc.started_at  = DateTime.now
    proc.closed_at   = nil
    proc.user_id     = Core.user ? Core.user.id : nil
    proc.state       = "running"
    proc.total       = 0
    proc.current     = 0
    proc.success     = 0
    proc.error       = 0
    proc.message     = nil
    proc.interrupt   = nil
    proc.attributes  = attrs
    proc.save
    return proc
  end

  def unlock
    self.closed_at = DateTime.now
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
